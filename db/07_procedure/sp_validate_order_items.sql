-- ==============================================================
-- File: sp_validate_order_items.sql
-- Purpose: Stored procedure to validate that all items in an order are available.
-- ==============================================================

CREATE OR ALTER PROCEDURE sp_ValidateOrderItems (@OrderID IDType)
AS
    BEGIN
        SET NOCOUNT ON;

        -- Table lưu các item không available
        DECLARE @UnavailableItems TABLE
            (
                ItemID         IDType,
                ItemName       NVARCHAR(128),
                RestaurantName NVARCHAR(128)
            );

        INSERT INTO @UnavailableItems
            (
                ItemID,
                ItemName,
                RestaurantName
            )
                    SELECT
                        mi.food_id,
                        mi.name,
                        r.name
                    FROM
                        order_items    oi
                        LEFT JOIN
                            menu_item  mi
                                ON oi.item_id = mi.food_id
                        LEFT JOIN
                            restaurant r
                                ON mi.restaurant_id = r.restaurant_id
                    WHERE
                        oi.order_id = @OrderID
                        AND (mi.food_id IS NULL OR mi.status <> 'AVAILABLE');

        -- Nếu có item không available thì báo lỗi
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    @UnavailableItems
            )
            BEGIN
                DECLARE
                    @ItemID         IDType,
                    @ItemName       NVARCHAR(128),
                    @RestaurantName NVARCHAR(128);

                DECLARE item_cursor CURSOR FOR
                    SELECT
                        ItemID,
                        ItemName,
                        RestaurantName
                    FROM
                        @UnavailableItems;

                OPEN item_cursor;
                FETCH NEXT FROM item_cursor
                INTO
                    @ItemID,
                    @ItemName,
                    @RestaurantName;

                WHILE @@FETCH_STATUS = 0
                    BEGIN
                        SET @ItemID = ISNULL(@ItemID, 'UNKNOWN');
                        SET @ItemName = ISNULL(@ItemName, 'UNKNOWN');
                        SET @RestaurantName = ISNULL(@RestaurantName, 'UNKNOWN');
                        RAISERROR(
                                     N'Item ID: %s, Name: %s from Restaurant: %s is not available or does not exist.', 16, 1, @ItemID,
                                     @ItemName, @RestaurantName
                                 );
                        FETCH NEXT FROM item_cursor
                        INTO
                            @ItemID,
                            @ItemName,
                            @RestaurantName;
                    END

                CLOSE item_cursor;
                DEALLOCATE item_cursor;

                RETURN;
            END
    END;
GO
