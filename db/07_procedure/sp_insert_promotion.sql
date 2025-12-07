-- =============================================
-- File: sp_insert_promotion.sql
-- Purpose: Stored procedure to insert a new promotion into the [promotion] table.
-- =============================================

CREATE OR ALTER PROCEDURE sp_InsertPromotion
    @Type               VARCHAR(32),
    @MinOrderValue      MoneyType,
    @DiscountValue      MoneyType,
    @PercentDiscount    INT             = NULL,
    @StartDate          DATE            = NULL,
    @EndDate            DATE            = NULL,
    @OrderID            IDType          = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewPromotionID IDType;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if OrderID exists (if provided)
        IF @OrderID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [order] WHERE order_id = @OrderID)
            BEGIN
                RAISERROR('Order ID does not exist.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;

        -- Check if Type is valid
        IF LOWER(@Type) NOT IN ( 'delivery_fee_discount', 'percentage_discount', 'fixed_amount_discount' )
        BEGIN
            RAISERROR('Invalid promotion type.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Additional validation based on Type
        IF LOWER(@Type) = 'percentage_discount'
           AND (
                   @PercentDiscount IS NULL
                   OR @PercentDiscount < 1
                   OR @PercentDiscount > 100
               )
        BEGIN
            RAISERROR('Percent discount must be between 1 and 100 for PERCENTAGE_DISCOUNT type.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Generate new Promotion ID
        SET @NewPromotionID = 'PRM' + FORMAT(NEXT VALUE FOR PRM_SQ, 'D13');

        -- Insert into [promotion]
        INSERT INTO [promotion]
        (
            promotion_id,
            order_id,
            -- type,
            min_order_value,
            start_date,
            end_date
        )
        VALUES
        (@NewPromotionID, @OrderID, @MinOrderValue, @StartDate, @EndDate);

        IF LOWER(@Type) = 'delivery_fee_discount'
        BEGIN
            INSERT INTO [delivery_fee_discount]
            (
                promotion_id,
                ship_discount_amount
            )
            VALUES
            (@NewPromotionID, @DiscountValue);
        END;
        ELSE IF LOWER(@Type) = 'percentage_discount'
        BEGIN
            INSERT INTO [percentage_discount]
            (
                promotion_id,
                discount_percent,
                max_discount_amount
            )
            VALUES
            (@NewPromotionID, @PercentDiscount, @DiscountValue);
        END;
        ELSE IF LOWER(@Type) = 'fixed_amount_discount'
        BEGIN
            INSERT INTO [fixed_amount_discount]
            (
                promotion_id,
                fixed_discount_amount
            )
            VALUES
            (@NewPromotionID, @DiscountValue);
        END;

        -- Commit transaction and return new Promotion ID
        COMMIT TRANSACTION;
        SELECT @NewPromotionID AS NewPromotionID;

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
