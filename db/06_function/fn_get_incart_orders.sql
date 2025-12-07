-- ==============================================================
-- File: fn_get_incart_orders.sql
-- Description:
--   Function to retrieve all orders with status 'IN_CART' for a given customer.
-- ==============================================================

CREATE OR ALTER FUNCTION fn_GetInCartOrders (@CustomerID IDType)
RETURNS TABLE
AS
RETURN
    (
        SELECT
            o.order_id       AS order_id,
            r.name           AS restaurant_name,
            SUM(oi.quantity) AS total_items,
            r.longitude      AS restaurant_longitude,
            r.latitude       AS restaurant_latitude,
            r.status         AS restaurant_status
        FROM
            [order]           o
            JOIN
                [restaurant]  r
                    ON o.restaurant_id = r.restaurant_id
            JOIN
                [order_items] oi
                    ON o.order_id = oi.order_id
        WHERE
            o.customer_id = @CustomerID
            AND o.status = 'IN_CART'
        GROUP BY
            o.order_id,
            r.name,
            r.longitude,
            r.latitude,
            r.status
    );
GO