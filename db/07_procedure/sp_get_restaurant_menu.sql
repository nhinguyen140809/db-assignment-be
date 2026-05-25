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
            mi.sold,
            ci.category_name
        FROM
            menu_item       mi
            JOIN category_items  ci
                ON mi.food_id = ci.menu_item_id AND mi.restaurant_id = ci.restaurant_id
        WHERE
            mi.restaurant_id = @RestaurantID
            AND mi.status <> 'DELETED'          -- Exclude deleted items
        ORDER BY
            mi.status       ASC,        -- AVAILABLE first
            mi.sold         DESC;       -- then by quantity sold
    END;
GO