-- ===============================================
-- File: sp_insert_payment_method.sql
-- Purpose: Stored procedure to insert a new payment method into the [payment_method] table.
-- ===============================================

CREATE OR ALTER PROCEDURE sp_InsertPaymentMethod
    @CustomerID     IDType,
    @Type           VARCHAR(32)     = 'CASH',
    @Provider       VARCHAR(64)     = NULL,
    @WalletNumber   VARCHAR(64)     = NULL,
    @BankName       VARCHAR(64)     = NULL,
    @CardNumber     VARCHAR(32)     = NULL,
    @ExpiryDate     DATE            = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewPaymentMethodID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if CustomerID exists
        IF NOT EXISTS (SELECT 1 FROM [customer] WHERE customer_id = @CustomerID)
        BEGIN
            RAISERROR('Customer ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check Type
        IF LOWER(@Type) NOT IN ('cash', 'e_wallet', 'bank_card')
        BEGIN
            RAISERROR('Invalid payment method type.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check required fields based on Type
        IF LOWER(@Type) = 'e_wallet'
           AND (
                   @Provider IS NULL
                   OR @WalletNumber IS NULL
               )
        BEGIN
            RAISERROR('Provider and Wallet Number are required for E_WALLET type.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        ELSE IF LOWER(@Type) = 'bank_card'
        BEGIN
            IF @BankName IS NULL
               OR @CardNumber IS NULL
               OR @ExpiryDate IS NULL
            BEGIN
                RAISERROR('Bank Name, Card Number, and Expiry Date are required for BANK_CARD type.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;

        -- Generate new Payment Method ID
        SET @NewPaymentMethodID = 'PAY' + FORMAT(NEXT VALUE FOR PAY_SQ, 'D13');

        -- Insert into [payment_method]
        INSERT INTO [payment_method]
        (
            payment_id,
            customer_id
            -- type
        )
        VALUES
        (@NewPaymentMethodID, @CustomerID);

        -- Insert into [e_wallet]
        IF LOWER(@Type) = 'e_wallet'
        BEGIN
            INSERT INTO [e_wallet]
            (
                e_wallet_id,
                provider,
                wallet_number
            )
            VALUES
            (@NewPaymentMethodID, @Provider, @WalletNumber);
        END
        ELSE IF LOWER(@Type) = 'bank_card'
        BEGIN
            INSERT INTO [bank_card]
            (
                bank_card_id,
                bank_name,
                card_number,
                expiry_date
            )
            VALUES
            (@NewPaymentMethodID, @BankName, @CardNumber, @ExpiryDate);
        END;
        ELSE IF LOWER(@Type) = 'cash'
        BEGIN
            INSERT INTO [cash]
            (
                cash_id
            )
            VALUES (@NewPaymentMethodID);
        END;

        -- Commit transaction and return new Payment Method ID
        COMMIT TRANSACTION;
        SELECT @NewPaymentMethodID AS NewPaymentMethodID;

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