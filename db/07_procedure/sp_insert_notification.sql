-- =====================================================
-- File: sp_insert_notification.sql
-- Purpose: Stored procedure to insert a new notification into the [notification] table.
-- =====================================================

CREATE OR ALTER PROCEDURE sp_InsertNotification
    @UserID         IDType,
    @OrderID        IDType,
    @Type           VARCHAR(32),
    @Message        NVARCHAR(1024),
    @IsRead         BIT             = 0,
    @SentAt         DATETIME        = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewNotificationID IDType;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if UserID exists
        IF NOT EXISTS (SELECT 1 FROM [user] WHERE user_id = @UserID)
        BEGIN
            RAISERROR('User ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if Type is valid
        -- IF @Type NOT IN ( 'ORDER_UPDATE', 'INVOICE' )
        -- BEGIN
        --     RAISERROR('Invalid notification type.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- If Type is ORDER_UPDATE, check if OrderID exists
        IF @OrderID IS NULL OR NOT EXISTS (SELECT 1 FROM [order] WHERE order_id = @OrderID)
        BEGIN
            RAISERROR('Order ID must be provided and exist for notification.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        

        -- Generate new Notification ID
        SET @NewNotificationID = 'NOT' + FORMAT(NEXT VALUE FOR NOT_SQ, 'D13');

        -- Set sent at timestamp
        SET @SentAt = ISNULL(@SentAt, GETDATE());

        -- Insert into [notification]
        INSERT INTO [notification]
        (
            notification_id,
            user_id,
            order_id,
            type,
            message,
            is_read,
            sent_at
        )
        VALUES
        (@NewNotificationID, @UserID, @OrderID, @Type, @Message, @IsRead, @SentAt);

        -- Commit transaction and return new Notification ID
        COMMIT TRANSACTION;
        SELECT @NewNotificationID AS NewNotificationID;

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