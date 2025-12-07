-- ===============================================
-- File: sp_insert_order.sql
-- Purpose: Stored procedure to insert a new order into the [order] table.
-- ===============================================

CREATE OR ALTER PROCEDURE sp_InsertOrder
    @CustomerID             IDType,
    @DriverID               IDType          = NULL,
    @RestaurantID           IDType,
    @DeliveryAddressID      IDType,
    @Status                 VARCHAR(32)     = 'IN_CART',
    @CustomerNote           NVARCHAR(1024)  = NULL,
    @DeliveryFee            MoneyType       = NULL,
    @OrderedAt              DATETIME        = NULL,
    @DeliveredAt            DATETIME        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewOrderID IDType;


    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if CustomerID exists
        IF NOT EXISTS (SELECT 1 FROM [customer] WHERE customer_id = @CustomerID)
        BEGIN
            RAISERROR('Customer ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Additional checks for DriverID, RestaurantID, DeliveryAddressID can be added here
        IF @DriverID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [driver] WHERE driver_id = @DriverID)
            BEGIN
                RAISERROR('Driver ID does not exist.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [restaurant]
            WHERE restaurant_id = @RestaurantID
        )
        BEGIN
            RAISERROR('Restaurant ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @DeliveryAddressID IS NOT NULL AND NOT EXISTS
        (
            SELECT 1
            FROM [delivery_address]
            WHERE address_id = @DeliveryAddressID
                  AND customer_id = @CustomerID
        )
        BEGIN
            RAISERROR('Delivery Address ID does not exist for the given Customer ID.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check invalid status
        -- IF @Status NOT IN ( 'IN_CART', 'PLACED', 'CONFIRMED', 'ASSIGNING_DRIVER',
        --                     'DRIVER_ASSIGNED', 'PREPARING', 'PICKUP_READY', 'DELIVERING',
        --                     'DELIVERED', 'COMPLETED', 'CANCELLED'
        --                   )
        -- BEGIN
        --     RAISERROR('Invalid Status.', 16, 1);
        --     ROLLBACK TRANSACTION;
        --     RETURN;
        -- END;

        -- Generate new Order ID
        SET @NewOrderID = 'ORD' + FORMAT(NEXT VALUE FOR ORD_SQ, 'D13');

        -- Set order date
        SET @OrderedAt = ISNULL(@OrderedAt, GETDATE());

        -- Insert into [order]
        INSERT INTO [order]
        (
            order_id,
            customer_id,
            driver_id,
            restaurant_id,
            delivery_id,
            status,
            customer_note,
            delivery_fee,
            ordered_at,
            delivered_at
        )
        VALUES
        (@NewOrderID,
         @CustomerID,
         @DriverID,
         @RestaurantID,
         @DeliveryAddressID,
         @Status,
         @CustomerNote,
         @DeliveryFee,
         @OrderedAt,
         @DeliveredAt
        );

        -- Commit transaction and return new Order ID
        COMMIT TRANSACTION;
        SELECT @NewOrderID AS NewOrderID;

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