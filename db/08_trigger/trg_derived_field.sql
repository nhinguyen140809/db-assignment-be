-- =====================================================
-- File: trg_derived_field.sql
-- Description: Trigger to maintain derived fields in related tables.
-- =====================================================

CREATE OR ALTER TRIGGER trg_OrderPlacement
ON [order]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update derived field 'order_at' in [order] table when status changes from 'IN_CART' to 'PLACED'
        DECLARE @PlacedOrders TABLE (order_id IDType PRIMARY KEY);

        INSERT INTO @PlacedOrders
            (
                order_id
            )
                    SELECT
                        i.order_id
                    FROM
                        inserted    i
                        JOIN
                            deleted d
                                ON i.order_id = d.order_id
                    WHERE
                        i.status = 'PLACED'
                        AND d.status = 'IN_CART';

        IF EXISTS
            (
                SELECT
                    1
                FROM
                    @PlacedOrders
            )
            BEGIN
                UPDATE
                    o
                SET
                    o.ordered_at = GETDATE()
                FROM
                    [order]           o
                    JOIN
                        @PlacedOrders po
                            ON o.order_id = po.order_id
                WHERE
                    o.ordered_at IS NULL; -- Only update if not already set

                -- Update price in order_items based on current menu_item price
                UPDATE
                    oi
                SET
                    oi.price = mi.price
                FROM
                    [order_items]     oi
                    JOIN
                        @PlacedOrders po
                            ON oi.order_id = po.order_id
                    JOIN
                        [menu_item]   mi
                            ON oi.restaurant_id = mi.restaurant_id
                               AND oi.item_id = mi.food_id
                WHERE
                    oi.price IS NULL; -- Only update if price is not already set

            END
    END
GO

CREATE OR ALTER TRIGGER trg_OrderDelivered
ON [order]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update field 'delivered_at' in [order] table when status changes to 'DELIVERED'
        WITH DeliveredOrders
        AS (
               SELECT
                   i.order_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.order_id = d.order_id
               WHERE
                   i.status = 'DELIVERED'
                   AND d.status <> 'DELIVERED'
           )
        UPDATE
            o
        SET
            o.delivered_at = GETDATE()
        FROM
            [order]             o
            JOIN
                DeliveredOrders do
                    ON o.order_id = do.order_id
        WHERE
            o.delivered_at IS NULL; -- Only update if not already set

        -- Update drived field 'sold' in [menu_item] table based on delivered orders
        WITH DeliveredOrders AS (
            SELECT i.order_id
            FROM inserted i
            JOIN deleted d ON i.order_id = d.order_id
            WHERE i.status = 'DELIVERED'
              AND d.status <> 'DELIVERED'
        ),
        ItemSold AS (
            SELECT
                oi.restaurant_id,
                oi.item_id,
                SUM(oi.quantity) AS total_qty
            FROM order_items oi
            JOIN DeliveredOrders do ON oi.order_id = do.order_id
            GROUP BY
                oi.restaurant_id,
                oi.item_id
        )
        UPDATE mi
        SET mi.sold = mi.sold + it.total_qty
        FROM menu_item mi
        JOIN ItemSold it
            ON mi.restaurant_id = it.restaurant_id
           AND mi.food_id = it.item_id;
    END
GO

CREATE OR ALTER TRIGGER trg_OrderPaymentPaid
ON [order_payments]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update derived field 'paid_at' in [order_payments] table when status changes to 'PAID'
        WITH PaidPayments
        AS (
               SELECT
                   i.order_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.order_id = d.order_id
               WHERE
                   i.status = 'PAID'
                   AND d.status = 'PENDING'
           )
        UPDATE
            op
        SET
            op.paid_at = GETDATE()
        FROM
            [order_payments]       op
            JOIN
                PaidPayments pp
                    ON op.order_id = pp.order_id
        WHERE
            op.paid_at IS NULL; -- Only update if not already set
    END
GO

-- Update derived field 'favourites' in [menu_item] table when a new favourite is added, removed, or updated
CREATE OR ALTER TRIGGER trg_MenuItemFavouriteInsert
ON [menu_item_favourite]
AFTER INSERT, DELETE, UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        -- Recalculate and update the 'favourites' count for each menu item

        UPDATE mi
        SET mi.favourites = ISNULL(fav.total_fav, 0)
        FROM menu_item mi
        LEFT JOIN (
            SELECT
                restaurant_id,
                menu_item_id,
                COUNT(*) AS total_fav
            FROM menu_item_favourite
            GROUP BY restaurant_id, menu_item_id
        ) AS fav
        ON mi.restaurant_id = fav.restaurant_id
        AND mi.food_id = fav.menu_item_id;
    END