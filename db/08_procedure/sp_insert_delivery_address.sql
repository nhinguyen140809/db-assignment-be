-- ========================================
-- File: sp_insert_delivery_address.sql
-- Purpose: Stored procedure to insert a new delivery address into the [delivery_address] table.
-- ========================================

CREATE OR ALTER PROCEDURE sp_InsertDeliveryAddress
    @CustomerID             IDType,
    @RecipientName          NVARCHAR(128),
    @Phone                  VARCHAR(16),
    @Longitude              LongitudeType,
    @Latitude               LatitudeType,
    @Details                NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewAddressID IDType;
    DECLARE @NextNumber BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if CustomerID exists
        IF NOT EXISTS (SELECT 1 FROM [customer] WHERE customer_id = @CustomerID)
        BEGIN
            RAISERROR('Customer ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Generate new Address ID
        SELECT @NextNumber = ISNULL(MAX(CAST(SUBSTRING([address_id], 4, LEN([address_id])) AS BIGINT)), 0) + 1
        FROM [delivery_address] WITH (UPDLOCK, HOLDLOCK)
        WHERE [customer_id] = @CustomerID;

        SET @NewAddressID = 'ADR' + RIGHT('0000000000000' + CAST(@NextNumber AS VARCHAR(13)), 13);

        -- Insert into [delivery_address]
        INSERT INTO [delivery_address]
        (
            address_id,
            customer_id,
            recipient_name,
            phone,
            longitude,
            latitude,
            details
        )
        VALUES
        (@NewAddressID, @CustomerID, @RecipientName, @Phone, @Longitude, @Latitude, @Details);

        -- Commit transaction and return new Address ID
        COMMIT TRANSACTION;
        SELECT @NewAddressID AS NewAddressID;

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