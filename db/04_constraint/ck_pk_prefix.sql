-- =======================================================
-- File: ck_pk_prefix.sql
-- Purpose: Define naming conventions for primary key and check constraints.
-- =======================================================

ALTER TABLE [user]
ADD CONSTRAINT CK_User_PrimaryKey_Format CHECK ([user_id] LIKE 'USR%');

ALTER TABLE [vehicle]
ADD CONSTRAINT CK_Vehicle_PrimaryKey_Format CHECK ([vehicle_id] LIKE 'VEH%');

ALTER TABLE [restaurant]
ADD CONSTRAINT CK_Restaurant_PrimaryKey_Format CHECK ([restaurant_id] LIKE 'RES%');

ALTER TABLE [delivery_address]
ADD CONSTRAINT CK_DeliveryAddress_PrimaryKey_Format CHECK ([address_id] LIKE 'ADR%');

ALTER TABLE [order]
ADD CONSTRAINT CK_Order_PrimaryKey_Format CHECK ([order_id] LIKE 'ORD%');

ALTER TABLE [payment_method]
ADD CONSTRAINT CK_PaymentMethod_PrimaryKey_Format CHECK ([payment_id] LIKE 'PAY%');

ALTER TABLE [promotion]
ADD CONSTRAINT CK_Promotion_PrimaryKey_Format CHECK ([promotion_id] LIKE 'PRM%');

ALTER TABLE [order_payments]
ADD CONSTRAINT CK_OrderPayment_PrimaryKey_Format CHECK ([order_payment_id] LIKE 'OPM%');

ALTER TABLE [menu_item]
ADD CONSTRAINT CK_MenuItem_PrimaryKey_Format CHECK ([food_id] LIKE 'FOO%');

--ALTER TABLE [support_request]
--ADD CONSTRAINT CK_SupportRequest_PrimaryKey_Format CHECK ([support_id] LIKE 'SUP%');

--ALTER TABLE [notification]
--ADD CONSTRAINT CK_Notification_PrimaryKey_Format CHECK ([notification_id] LIKE 'NOT%');