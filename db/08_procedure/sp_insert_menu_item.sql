-- =============================================
-- File: sp_insert_menu_item.sql
-- Purpose: Stored procedure to insert a new menu item into the [menu_item] table.
-- =============================================

CREATE OR ALTER PROCEDURE sp_InsertMenuItem
    @RestaurantID       IDType,
    @Name               NVARCHAR(128),
    @Description        NVARCHAR(512)   = NULL,
    @Price              MoneyType,
    @Status             VARCHAR(32)     = 'UNAVAILABLE'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewMenuItemID IDType;
    DECLARE @NextNumber BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if RestaurantID exists
        IF NOT EXISTS (SELECT 1 FROM [restaurant] WHERE restaurant_id = @RestaurantID)
        BEGIN
            RAISERROR('Restaurant ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Generate new Menu Item ID
        SELECT @NextNumber = ISNULL(MAX(CAST(SUBSTRING([food_id], 4, LEN([food_id])) AS BIGINT)), 0) + 1
        FROM [menu_item] WITH (UPDLOCK, HOLDLOCK)
        WHERE [restaurant_id] = @RestaurantID;
        
        SET @NewMenuItemID = 'FOO' + RIGHT('0000000000000' + CAST(@NextNumber AS VARCHAR(13)), 13);

        -- Check invalid status
        -- IF @Status NOT IN ( 'AVAILABLE', 'UNAVAILABLE' )
        -- BEGIN
        --     RAISERROR('Invalid Status.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- Insert into [menu_item]
        INSERT INTO [menu_item]
        (
            food_id,
            restaurant_id,
            name,
            description,
            price,
            status
        )
        VALUES
        (@NewMenuItemID, @RestaurantID, @Name, @Description, @Price, @Status);

        -- Commit transaction and return new Menu Item ID
        COMMIT TRANSACTION;
        SELECT @NewMenuItemID AS NewMenuItemID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO