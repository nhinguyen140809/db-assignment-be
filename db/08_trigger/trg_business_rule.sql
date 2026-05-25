-- ===========================================
-- File: trg_business_rule.sql
-- Description: Trigger to enforce business rules on multiple tables.
-- ===========================================

CREATE OR ALTER TRIGGER trg_OrderItem_RestaurantConsistency
ON [order_items]
AFTER INSERT, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;
        -- Check restaurant_id consistency
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    inserted    i
                    JOIN
                        [order] o
                            ON i.order_id = o.order_id
                WHERE
                    i.restaurant_id <> o.restaurant_id
            )
            BEGIN
                RAISERROR('All items in an order must belong to the same restaurant that the order belongs to.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END
GO

CREATE OR ALTER TRIGGER trg_OrderItem_InCartOnly
ON [order_items]
AFTER INSERT, UPDATE, DELETE
AS
    BEGIN
        SET NOCOUNT ON;
        -- Check if the inserted, updated, or deleted order is IN_CART
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    (
                        SELECT
                            order_id
                        FROM
                            inserted
                        UNION ALL
                        SELECT
                            order_id
                        FROM
                            deleted
                    )           AS od
                    JOIN
                        [order] o
                            ON od.order_id = o.order_id
                WHERE
                    o.status <> 'IN_CART'
            )
            BEGIN
                RAISERROR('Modifications to order items are only allowed when the order status is IN_CART.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END
GO


CREATE OR ALTER TRIGGER trg_Order_RemoveEmptyOrder
ON [order_items]
AFTER DELETE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Xóa các order thuộc IN_CART nhưng không còn order_item
        DELETE o
        FROM
            [order] o
        WHERE
            o.status = 'IN_CART'
            AND o.order_id IN (
                                  SELECT DISTINCT
                                      order_id
                                  FROM
                                      deleted
                              )
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    order_items oi
                WHERE
                    oi.order_id = o.order_id
            );
    END
GO

CREATE OR ALTER TRIGGER trg_RestaurantNotOpen
ON [restaurant]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        WITH UpdatedRestaurants
        AS (
               SELECT
                   i.restaurant_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.restaurant_id = d.restaurant_id
               WHERE
                   i.status <> 'OPEN'
                   AND d.status = 'OPEN'
           )
        -- If a restaurant's status changes from 'OPEN' to any other status,
        -- set all its menu items to 'UNAVAILABLE'
        UPDATE
            mi
        SET
            mi.status = 'UNAVAILABLE'
        FROM
            [menu_item]            mi
            JOIN
                UpdatedRestaurants ur
                    ON mi.restaurant_id = ur.restaurant_id;

    END
GO

CREATE OR ALTER TRIGGER trg_CustomerReviewDriver
ON [driver_review]
AFTER INSERT, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Ensure that a customer can only review a driver if they have an order delivered by that driver
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    inserted    ir
                    JOIN
                        [order] o
                            ON ir.order_id = o.order_id
                WHERE
                    ir.customer_id <> o.customer_id -- review is not from the customer who placed the order
                    OR ir.driver_id <> o.driver_id -- review is not for the driver who delivered the order
            )
            BEGIN
                RAISERROR(
                             'Invalid driver review: Customer can not review drivers they have not had orders delivered by.',
                             16, 1
                         );
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END
GO

CREATE OR ALTER TRIGGER trg_CustomerReviewRestaurant
ON [restaurant_review]
AFTER INSERT, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Ensure that a customer can only review a restaurant if they have an order from that restaurant
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    inserted    ir
                    JOIN
                        [order] o
                            ON ir.order_id = o.order_id
                WHERE
                    ir.customer_id <> o.customer_id -- review is not from the customer who placed the order
                    OR ir.restaurant_id <> o.restaurant_id -- review is not for the restaurant of the order
            )
            BEGIN
                RAISERROR(
                             'Invalid restaurant review: Customer can not review restaurants they have not ordered from.',
                             16, 1
                         );
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END
GO

CREATE OR ALTER TRIGGER trg_ValidateOrderPayment
ON [order_payments]
AFTER INSERT, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Ensure that the payment method belongs to the customer who placed the order
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    inserted           ip
                    JOIN
                        [order]        o
                            ON ip.order_id = o.order_id
                    JOIN
                        payment_method pm
                            ON ip.payment_method_id = pm.payment_id
                WHERE
                    o.customer_id <> pm.customer_id -- Payment method not owned by the customer who placed the order
            )
            BEGIN
                RAISERROR(
                             'Invalid payment: Payment method does not belong to the customer who placed the order.',
                             16, 1
                         );
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END
GO

CREATE OR ALTER TRIGGER trg_ValidateOperatingHours
ON [operating_hour]
AFTER INSERT, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF EXISTS
            (
                SELECT
                    1
                FROM
                    inserted           i
                    JOIN
                        operating_hour oh
                            ON i.restaurant_id = oh.restaurant_id
                               AND i.dow = oh.dow
                               AND i.open_time < oh.close_time
                               AND i.close_time > oh.open_time
                               AND NOT (
                                           i.open_time = oh.open_time
                                           AND i.close_time = oh.close_time
                                           AND i.dow = oh.dow
                                           AND i.restaurant_id = oh.restaurant_id
                                       )
            )
            BEGIN
                RAISERROR('Overlapping operating hours detected.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END;
GO

CREATE OR ALTER TRIGGER trg_Customer_SetNullRecommended
ON [customer]
AFTER DELETE
AS
    BEGIN
        -- Set recommended_customer_id = NULL cho các customer khác
        UPDATE
            c
        SET
            recommended_customer_id = NULL
        FROM
            customer    c
            JOIN
                deleted d
                    ON c.recommended_customer_id = d.customer_id;
    END;
GO

-- Trigger when delete customer, SET NULL driver_review.customer_id and restaurant_review.customer_id, delete menu_item_favourite
CREATE OR ALTER TRIGGER trg_Customer_Delete
ON [customer]
AFTER DELETE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Set NULL driver_review.customer_id
        UPDATE
            dr
        SET
            dr.customer_id = NULL
        FROM
            driver_review    dr
            JOIN
                deleted        d
                    ON dr.customer_id = d.customer_id;

        -- Set NULL restaurant_review.customer_id
        UPDATE
            rr
        SET
            rr.customer_id = NULL
        FROM
            restaurant_review    rr
            JOIN
                deleted           d
                    ON rr.customer_id = d.customer_id;

        -- Delete menu_item_favourite
        DELETE mif
        FROM
            menu_item_favourite    mif
            JOIN
                deleted              d
                    ON mif.customer_id = d.customer_id;
    END;
GO

-- Trigger when delete driver, delete driver_review, SET NULL order.driver_id
CREATE OR ALTER TRIGGER trg_Driver_Delete
ON [driver]
AFTER DELETE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Delete driver_review
        DELETE dr
        FROM
            driver_review    dr
            JOIN
                deleted        d
                    ON dr.driver_id = d.driver_id;

        -- Set NULL order.driver_id
        UPDATE
            o
        SET
            o.driver_id = NULL
        FROM
            [order]    o
            JOIN
                deleted    d
                    ON o.driver_id = d.driver_id;
    END;
GO