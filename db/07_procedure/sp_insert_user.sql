-- ==================================================
-- File: sp_insert_user.sql
-- Purpose: Stored procedures to insert a new user into the [user] table.
-- ==================================================

GO
CREATE OR ALTER PROCEDURE sp_InsertCustomer
    @Name                   NVARCHAR(128),
    @Email                  VARCHAR(64),
    @PasswordHash           VARCHAR(64),
    @RegistrationDate       DATE            = NULL,
    @Phone                  VARCHAR(16)     = NULL,
    @RecommendedCustomerID  IDType          = NULL
AS
BEGIN
    DECLARE @NewUserID IDType;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Check for duplicate email
        IF EXISTS (SELECT 1 FROM [user] WHERE email = @Email)
        BEGIN
            RAISERROR('Email already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        -- If RecommendedCustomerID is provided, check if it exists
        IF @RecommendedCustomerID IS NOT NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM [customer]
                WHERE customer_id = @RecommendedCustomerID
            )
            BEGIN
                RAISERROR('Recommended Customer ID does not exist.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Generate new User ID and set registration date
        SET @NewUserID = 'USR' + FORMAT(NEXT VALUE FOR USR_SQ, 'D13');
        SET @RegistrationDate = ISNULL(@RegistrationDate, GETDATE());

        -- Insert into [user] and [customer] tables
        INSERT INTO [user]
        (
            user_id,
            name,
            email,
            password_hash,
            phone,
            -- role,
            registration_date
        )
        VALUES
        (@NewUserID, @Name, @Email, @PasswordHash, @Phone, @RegistrationDate);

        INSERT INTO [customer]
        (
            customer_id,
            recommended_customer_id
        )
        VALUES
        (@NewUserID, @RecommendedCustomerID);

        -- Commit transaction and return new Customer ID
        COMMIT TRANSACTION;
        SELECT @NewUserID AS NewCustomerID;
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
CREATE OR ALTER PROCEDURE sp_InsertDriver
    @Name                   NVARCHAR(128),
    @Email                  VARCHAR(64),
    @PasswordHash           VARCHAR(64),
    @RegistrationDate       DATE            = NULL,
    @Phone                  VARCHAR(16)     = NULL,
    @DriverLicenseID        VARCHAR(64)     = NULL,
    @Status                 VARCHAR(32)     = 'OFFLINE' 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewDriverID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check duplicate email and vehicle existence
        IF EXISTS (SELECT 1 FROM [user] WHERE email = @Email)
        BEGIN
            RAISERROR('Email already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check Status validity
        -- IF @Status NOT IN ( 'OFFLINE', 'ONLINE', 'BUSY' )
        -- BEGIN
        --     RAISERROR('Invalid Status.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- Generate new Driver ID
        SET @NewDriverID = 'USR' + FORMAT(NEXT VALUE FOR USR_SQ, 'D13');

        -- Set registration date
        SET @RegistrationDate = ISNULL(@RegistrationDate, GETDATE());

        -- Insert into [user]
        INSERT INTO [user]
        (
            user_id,
            name,
            email,
            password_hash,
            phone,
            -- role,
            registration_date
        )
        VALUES
        (   @NewDriverID,
            @Name,
            @Email,
            @PasswordHash,
            @Phone,
            -- 'DRIVER', -- role fixed for this procedure
            @RegistrationDate
        );

        -- Insert into [driver]
        INSERT INTO driver
        (
            driver_id,
            driver_license_id,
            status
        )
        VALUES
        (@NewDriverID, @DriverLicenseID, @Status);

        -- Commit transaction and return new Driver ID
        COMMIT TRANSACTION;
        SELECT @NewDriverID AS NewDriverID;
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

CREATE OR ALTER PROCEDURE sp_InsertRestaurantOwner
    @Name                   NVARCHAR(128),
    @Email                  VARCHAR(64),
    @PasswordHash           VARCHAR(64),
    @RegistrationDate       DATE            = NULL,
    @Phone                  VARCHAR(16)     = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewOwnerID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check duplicate email
        IF EXISTS (SELECT 1 FROM [user] WHERE email = @Email)
        BEGIN
            RAISERROR('Email already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Generate new Owner ID
        SET @NewOwnerID = 'USR' + FORMAT(NEXT VALUE FOR USR_SQ, 'D13');

        -- Set registration date
        SET @RegistrationDate = ISNULL(@RegistrationDate, GETDATE());

        -- Insert into [user]
        INSERT INTO [user]
        (
            user_id,
            name,
            email,
            password_hash,
            phone,
            -- role,
            registration_date
        )
        VALUES
        (   @NewOwnerID,
            @Name,
            @Email,
            @PasswordHash,
            @Phone,
            -- 'OWNER', -- role fixed for this procedure
            @RegistrationDate
        );

        -- Insert into [restaurant_owner]
        INSERT INTO restaurant_owner
        (
            owner_id
        )
        VALUES (@NewOwnerID);

        -- Commit transaction and return new Owner ID
        COMMIT TRANSACTION;
        SELECT @NewOwnerID AS NewOwnerID;

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