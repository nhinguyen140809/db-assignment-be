-- =====================================================
-- File: trg_derived_field.sql
-- Description: Trigger to maintain derived fields in related tables.
-- =====================================================

CREATE OR ALTER TRIGGER trg_OrderPlacement
ON [order]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update derived field 'order_at' in [order] table when status changes from 'IN_CART' to 'PLACED'
        WITH PlacedOrders
        AS (
               SELECT
                   i.order_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.order_id = d.order_id
               WHERE
                   i.status = 'PLACED'
                   AND d.status = 'IN_CART'
           )
        UPDATE
            o
        SET
            o.ordered_at = GETDATE()
        FROM
            [order]          o
            JOIN
                PlacedOrders po
                    ON o.order_id = po.order_id
        WHERE
            o.ordered_at IS NULL; -- Only update if not already set
    END
GO

CREATE OR ALTER TRIGGER trg_OrderDelivered
ON [order]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update derived field 'delivered_at' in [order] table when status changes to 'DELIVERED'
        WITH DeliveredOrders
        AS (
               SELECT
                   i.order_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.order_id = d.order_id
               WHERE
                   i.status = 'DELIVERED'
                   AND d.status = 'DELIVERING'
           )
        UPDATE
            o
        SET
            o.delivered_at = GETDATE()
        FROM
            [order]             o
            JOIN
                DeliveredOrders do
                    ON o.order_id = do.order_id
        WHERE
            o.delivered_at IS NULL; -- Only update if not already set
    END
GO

CREATE OR ALTER TRIGGER trg_OrderPaymentPaid
ON [order_payments]
AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(status)
            RETURN;

        -- Update derived field 'paid_at' in [order_payments] table when status changes to 'PAID'
        WITH PaidPayments
        AS (
               SELECT
                   i.order_id
               FROM
                   inserted    i
                   JOIN
                       deleted d
                           ON i.order_id = d.order_id
               WHERE
                   i.status = 'PAID'
                   AND d.status = 'PENDING'
           )
        UPDATE
            op
        SET
            op.paid_at = GETDATE()
        FROM
            [order_payments]       op
            JOIN
                PaidPayments pp
                    ON op.order_id = pp.order_id
        WHERE
            op.paid_at IS NULL; -- Only update if not already set
    END
GO