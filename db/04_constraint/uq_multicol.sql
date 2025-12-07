-- ===================================================
-- File: uq_multicol.sql
-- Purpose: Define unique constraints involving multiple columns.
-- ===================================================

ALTER TABLE [delivery_address]
ADD CONSTRAINT UQ_DeliveryAddress_Columns
    UNIQUE ([customer_id], [recipient_name], [phone], [longitude], [latitude], [details]);

