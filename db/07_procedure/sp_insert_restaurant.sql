-- ==============================================
-- File:   sp_insert_restaurant.sql
-- Purpose: Stored procedure to insert a new restaurant into the [restaurant] table.
-- ==============================================

CREATE OR ALTER PROCEDURE sp_InsertRestaurant
    @OwnerID                    IDType,
    @Name                       NVARCHAR(128),
    @Phone                      VARCHAR(16)     = NULL,
    @Email                      VARCHAR(64)     = NULL, 
    @AddressDetails             NVARCHAR(256)   = NULL,
    @Longitude                  LongitudeType   = NULL,
    @Latitude                   LatitudeType    = NULL,
    @RegistrationDate           DATE            = NULL,
    @Status                     VARCHAR(32)     = 'CLOSED'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewRestaurantID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if OwnerID exists
        IF NOT EXISTS (SELECT 1 FROM [restaurant_owner] WHERE owner_id = @OwnerID)
        BEGIN
            RAISERROR('Owner ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check invalid status
        -- IF @Status NOT IN ( 'OPEN', 'CLOSED', 'UNAVAILABLE' )
        -- BEGIN
        --     RAISERROR('Invalid Status.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- Generate new Restaurant ID
        SET @NewRestaurantID = 'RES' + FORMAT(NEXT VALUE FOR RES_SQ, 'D13');

        -- Set registration date
        SET @RegistrationDate = ISNULL(@RegistrationDate, GETDATE());

        -- Insert into [restaurant]
        INSERT INTO [restaurant]
        (
            restaurant_id,
            owner_id,
            name,
            phone,
            email,
            address_details,
            longitude,
            latitude,
            registration_date,
            status
        )
        VALUES
        (
            @NewRestaurantID,
            @OwnerID,
            @Name,
            @Phone,
            @Email,
            @AddressDetails,
            @Longitude,
            @Latitude,
            @RegistrationDate,
            @Status
        );

        -- Commit transaction and return new Restaurant ID
        COMMIT TRANSACTION;
        SELECT @NewRestaurantID AS NewRestaurantID;

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