-- =============================================
-- File: sp_insert_support_request.sql
-- Purpose: Stored procedure to insert a new support request into the [support_request] table.
-- =============================================

CREATE OR ALTER PROCEDURE sp_InsertSupportRequest
    @UserID         IDType,
    @IssueType      VARCHAR(32)         = 'OTHER',
    @Description    NVARCHAR(2048),
    @CreatedAt      DATE                = NULL,
    @Status         VARCHAR(32)         = 'PENDING',
    @AdminUsername  VARCHAR(128)        = NULL,
    @OrderID        IDType              = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewSupportRequestID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if UserID exists
        IF NOT EXISTS (SELECT 1 FROM [user] WHERE user_id = @UserID)
        BEGIN
            RAISERROR('User ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if IssueType is valid
        -- IF @IssueType NOT IN ( 'ORDER_ISSUE', 'PAYMENT_ISSUE', 'DELIVERY_ISSUE', 'APP_FEEDBACK', 'OTHER' )
        -- BEGIN
        --     RAISERROR('Invalid Issue Type.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- If Type is ORDER_ISSUE, check if OrderID exists
        IF @IssueType = 'ORDER_ISSUE'
        BEGIN
            IF @OrderID IS NULL OR NOT EXISTS (SELECT 1 FROM [order] WHERE order_id = @OrderID)
            BEGIN
                RAISERROR('Order ID must be provided and exist for ORDER_ISSUE type.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;


        -- Generate new Support Request ID
        SET @NewSupportRequestID = 'SUP' + FORMAT(NEXT VALUE FOR SUP_SQ, 'D13');

        -- Set created at date
        SET @CreatedAt = ISNULL(@CreatedAt, GETDATE());

        -- Check invalid status
        -- IF @Status NOT IN ( 'PENDING', 'IN_PROGRESS', 'RESOLVED' )
        -- BEGIN
            -- RAISERROR('Invalid Status.', 16, 1);
            -- ROLLBACK TRANSACTION;
            -- RETURN;
        -- END;

        -- Insert into [support_request]
        INSERT INTO [support_request]
        (
            support_id,
            user_id,
            issue_type,
            description,
            created_at,
            status,
            administrator_username,
            order_id
        )
        VALUES
        (@NewSupportRequestID, @UserID, @IssueType, @Description, @CreatedAt, @Status, @AdminUsername, @OrderID);

        -- Commit transaction and return new Support Request ID
        COMMIT TRANSACTION;
        SELECT @NewSupportRequestID AS NewSupportRequestID;

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