-- ============================================
-- File: sp_insert_vehicle.sql
-- Purpose: Stored procedure to insert a new vehicle into the [vehicle] table.
-- ============================================

CREATE OR ALTER PROCEDURE sp_InsertVehicle
    @VehicleColor   NVARCHAR(32),
    @Model          VARCHAR(32),
    @LicensePlate   VARCHAR(32)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewVehicleID IDType;

    BEGIN TRY -- nếu license plate cần unique thì thêm kiểm tra trong này, nếu không thì không cần try catch
        BEGIN TRANSACTION;

        -- Generate new Vehicle ID
        SET @NewVehicleID = 'VEH' + FORMAT(NEXT VALUE FOR VEH_SQ, 'D13');

        -- Insert into [vehicle]
        INSERT INTO [vehicle]
        (
            vehicle_id,
            vehicle_color,
            model,
            license_plate
        )
        VALUES
        (@NewVehicleID, @VehicleColor, @Model, @LicensePlate);

        -- Commit transaction and return new Vehicle ID
        COMMIT TRANSACTION;
        SELECT @NewVehicleID AS NewVehicleID;

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