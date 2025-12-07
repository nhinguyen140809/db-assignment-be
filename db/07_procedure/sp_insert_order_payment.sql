-- =============================================
-- File: sp_insert_order_payment.sql
-- Purpose: Stored procedure to insert a new order payment into the [order_payments] table
-- =============================================


CREATE OR ALTER PROCEDURE sp_InsertOrderPayment
    @OrderID                IDType,
    @PaymentMethodID        IDType,
    @Status                 VARCHAR(32)     = 'UNPAID',
    @CreatedAt              DATETIME        = NULL,
    @PaidAt                 DATETIME        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewOrderPaymentID IDType;
    DECLARE @NextNumber BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if OrderID exists
        IF NOT EXISTS (SELECT 1 FROM [order] WHERE order_id = @OrderID)
        BEGIN
            RAISERROR('Order ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if PaymentMethodID exists
        IF NOT EXISTS (SELECT 1 FROM [payment_method] WHERE [payment_id] = @PaymentMethodID)
        BEGIN
            RAISERROR('Payment Method ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check invalid status
        -- IF @Status NOT IN ( 'UNPAID', 'PENDING', 'PAID', 'FAILED', 'REFUNDING', 'REFUNDED' )
        -- BEGIN
        --     RAISERROR('Invalid Status.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- Generate new Order Payment ID
        SELECT @NextNumber = ISNULL(MAX(CAST(SUBSTRING([order_payment_id], 4, LEN([order_payment_id])) AS BIGINT)), 0) + 1
        FROM [order_payments] WITH (UPDLOCK, HOLDLOCK)
        WHERE [order_id] = @OrderID;

        SET @NewOrderPaymentID = 'OPM' + FORMAT(@NextNumber, 'D13');

        -- Set created at timestamp
        SET @CreatedAt = ISNULL(@CreatedAt, GETDATE());

        -- Insert into [order_payment]
        INSERT INTO [order_payments]
        (
            order_payment_id,
            order_id,
            payment_method_id,
            status,
            created_at,
            paid_at
        )
        VALUES
        (@NewOrderPaymentID, @OrderID, @PaymentMethodID, @Status, @CreatedAt, @PaidAt);

        -- Commit transaction and return new Order Payment ID
        COMMIT TRANSACTION;
        SELECT @NewOrderPaymentID AS NewOrderPaymentID;

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