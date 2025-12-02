-- ==============================================
-- File: pk_multicol.sql
-- Purpose: Define composite primary key constraints for tables.
-- ==============================================

ALTER TABLE [delivery_address]
ADD CONSTRAINT PK_DeliveryAddress
    PRIMARY KEY ([address_id], [customer_id]);

ALTER TABLE [operating_hour]
ADD CONSTRAINT PK_OperatingHour
    PRIMARY KEY ([restaurant_id], [dow], [open_time]);

ALTER TABLE [menu_item]
ADD CONSTRAINT PK_MenuItem
    PRIMARY KEY ([restaurant_id], [food_id]);

ALTER TABLE [menu_item_favourite]
ADD CONSTRAINT PK_MenuItemFavourite
    PRIMARY KEY ([customer_id], [restaurant_id], [menu_item_id]);

ALTER TABLE [category_items]
ADD CONSTRAINT PK_CategoryItems
    PRIMARY KEY ([category_name], [restaurant_id], [menu_item_id]);

ALTER TABLE [order_items]
ADD CONSTRAINT PK_OrderItems
    PRIMARY KEY ([order_id], [item_id], [restaurant_id]);

ALTER TABLE [order_payments]
ADD CONSTRAINT PK_OrderPayment
    PRIMARY KEY ([order_payment_id], [order_id]);