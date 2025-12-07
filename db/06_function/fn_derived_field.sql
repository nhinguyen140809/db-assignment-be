-- ===================================================
-- File: fn_derived_field.sql
-- Description:
--   Function to calculate a derived field based on existing data.
--   Example: Calculate the average rating of a restaurant from its reviews.
-- ===================================================

CREATE OR ALTER FUNCTION fn_RestaurantAverageRating (@RestaurantID IDType)
RETURNS FLOAT
AS
    BEGIN
        DECLARE @AverageRating FLOAT;

        SELECT
            @AverageRating = AVG(CAST(rr.rating_point AS FLOAT))
        FROM
            [restaurant_review] rr
        WHERE
            rr.restaurant_id = @RestaurantID;

        RETURN @AverageRating;
    END;
GO

CREATE OR ALTER FUNCTION fn_DriverAverageRating (@DriverID IDType)
RETURNS FLOAT
AS
    BEGIN
        DECLARE @AverageRating FLOAT;

        SELECT
            @AverageRating = AVG(CAST(dr.rating_point AS FLOAT))
        FROM
            [driver_review] dr
        WHERE
            dr.driver_id = @DriverID;

        RETURN @AverageRating;
    END;
GO

CREATE OR ALTER FUNCTION fn_CalculateOrderSubtotal (@OrderID IDType)
RETURNS MoneyType
AS
    BEGIN
        DECLARE @Subtotal MoneyType;
        -- Price in order_items can be NULL if not set yet
        IF EXISTS (SELECT 1 FROM [order_items] oi WHERE oi.order_id = @OrderID AND oi.price IS NULL)
        BEGIN
            -- Calculate based on current menu_item prices
            SELECT
                @Subtotal = SUM(mi.price * oi.quantity)
            FROM
                [order_items] oi
                JOIN
                    [menu_item] mi
                        ON oi.restaurant_id = mi.restaurant_id
                           AND oi.item_id = mi.food_id
            WHERE
                oi.order_id = @OrderID;
        END
        ELSE
        BEGIN
            -- Calculate based on stored prices in order_items
            SELECT
                @Subtotal = SUM(oi.price * oi.quantity)
            FROM
                [order_items] oi
            WHERE
                oi.order_id = @OrderID;
        END

        RETURN @Subtotal;
    END;
GO

CREATE OR ALTER FUNCTION fn_MenuItemFavoritedCount (@RestaurantID IDType, @MenuItemID IDType)
RETURNS INT
AS
    BEGIN
        DECLARE @FavoritedCount INT;

        SELECT
            @FavoritedCount = COUNT(*)
        FROM
            [menu_item_favourite] mif
        WHERE
            mif.restaurant_id = @RestaurantID
            AND mif.menu_item_id = @MenuItemID;

        RETURN @FavoritedCount;
    END;
GO