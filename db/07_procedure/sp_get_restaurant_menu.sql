-- =============================================
-- File: sp_GetRestaurantMenu.sql
-- Purpose: Return restaurant menu with item info and number of times sold
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetRestaurantMenu @RestaurantID IDType
AS
    BEGIN
        SET NOCOUNT ON;

        -- Select menu items with total quantity sold
        SELECT
            mi.food_id,
            mi.name,
            mi.price,
            mi.status,
            ISNULL(SUM(oi.quantity), 0) AS total_sold
        FROM
            menu_item       mi
            LEFT JOIN
                order_items oi
                    ON mi.food_id = oi.item_id
                       AND mi.restaurant_id = oi.restaurant_id
        WHERE
            mi.restaurant_id = @RestaurantID
            AND mi.status <> 'DELETED'          -- Exclude deleted items
        GROUP BY
            mi.food_id,
            mi.name,
            mi.price,
            mi.status
        ORDER BY
            mi.status       ASC,        -- AVAILABLE first
            total_sold      DESC;       -- then by quantity sold
    END;
GO