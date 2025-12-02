-- ===================================================
-- File: 03_relations.sql
-- Purpose: Define relationships between tables.
-- Includes:
--   - Foreign Keys (FK)
--   - ON DELETE / ON UPDATE rules
-- ===================================================


-- Khá nhiều chỗ cascade delete, không biết có ổn không?
ALTER TABLE [customer]
ADD CONSTRAINT FK_Customer_User
    FOREIGN KEY ([customer_id])
    REFERENCES [user] ([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [customer]
ADD CONSTRAINT FK_Customer_RecommendedCustomer
    FOREIGN KEY ([recommended_customer_id])
    REFERENCES [customer] ([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [driver]
ADD CONSTRAINT FK_Driver_User
    FOREIGN KEY ([driver_id]) 
    REFERENCES [user] ([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [driver]
ADD CONSTRAINT FK_Driver_Vehicle
    FOREIGN KEY ([vehicle_id]) 
    REFERENCES [vehicle] ([vehicle_id]) ON UPDATE CASCADE;

ALTER TABLE [restaurant_owner]
ADD CONSTRAINT FK_RestaurantOwner_User
    FOREIGN KEY ([owner_id]) 
    REFERENCES [user] ([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [delivery_address]
ADD CONSTRAINT FK_DeliveryAddress_Customer
    FOREIGN KEY ([customer_id]) 
    REFERENCES [customer] ([customer_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [payment_method]
ADD CONSTRAINT FK_PaymentMethod_Customer
    FOREIGN KEY ([customer_id])
    REFERENCES [customer] ([customer_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [e_wallet]
ADD CONSTRAINT FK_EWallet_PaymentMethod
    FOREIGN KEY ([e_wallet_id])
    REFERENCES [payment_method] ([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [bank_card]
ADD CONSTRAINT FK_BankCard_PaymentMethod
    FOREIGN KEY ([bank_card_id])
    REFERENCES [payment_method] ([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [cash]
ADD CONSTRAINT FK_Cash_PaymentMethod
    FOREIGN KEY ([cash_id])
    REFERENCES [payment_method] ([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE [restaurant]
ADD CONSTRAINT FK_Restaurant_Owner
    FOREIGN KEY ([owner_id])
    REFERENCES [restaurant_owner] ([owner_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [operating_hour]
ADD CONSTRAINT FK_OperatingHour_Restaurant
    FOREIGN KEY ([restaurant_id])
    REFERENCES [restaurant] ([restaurant_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [menu_item]
ADD CONSTRAINT FK_MenuItem_Restaurant
    FOREIGN KEY ([restaurant_id])
    REFERENCES [restaurant] ([restaurant_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [menu_item_favourite]
ADD CONSTRAINT FK_MenuItemFavourite_Customer
    FOREIGN KEY ([customer_id])
    REFERENCES [customer] ([customer_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [menu_item_favourite]
ADD CONSTRAINT FK_MenuItemFavourite_MenuItem
    FOREIGN KEY ([restaurant_id], [menu_item_id])
    REFERENCES [menu_item] ([restaurant_id], [food_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [restaurant_review]
ADD CONSTRAINT FK_RestaurantReview_Order
    FOREIGN KEY ([order_id])
    REFERENCES [order] ([order_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [restaurant_review]
ADD CONSTRAINT FK_RestaurantReview_Customer
    FOREIGN KEY ([customer_id])
    REFERENCES [customer] ([customer_id]) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE [restaurant_review]
ADD CONSTRAINT FK_RestaurantReview_Restaurant
    FOREIGN KEY ([restaurant_id]) 
    REFERENCES [restaurant] ([restaurant_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [category_items]
ADD CONSTRAINT FK_CategoryItems_Category
    FOREIGN KEY ([category_name])
    REFERENCES [category] ([name]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [category_items]
ADD CONSTRAINT FK_CategoryItems_MenuItem
    FOREIGN KEY ([restaurant_id],[menu_item_id])
    REFERENCES [menu_item] ([restaurant_id],[food_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [order]
ADD CONSTRAINT FK_Order_Driver
    FOREIGN KEY ([driver_id])
    REFERENCES [driver] ([driver_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [order]
ADD CONSTRAINT FK_Order_Restaurant
    FOREIGN KEY ([restaurant_id])
    REFERENCES [restaurant] ([restaurant_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [order]
ADD CONSTRAINT FK_Order_CustomerDeliveryAddress
    FOREIGN KEY ([delivery_id], [customer_id])
    REFERENCES [delivery_address] ([address_id], [customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [order_items]
ADD CONSTRAINT FK_OrderItems_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [order_items]
ADD CONSTRAINT FK_OrderItems_MenuItem
    FOREIGN KEY ([restaurant_id], [item_id]) 
    REFERENCES [menu_item] ([restaurant_id], [food_id]) ON DELETE CASCADE ON UPDATE CASCADE;    -- menu item can be deleted

ALTER TABLE [order_payments]
ADD CONSTRAINT FK_OrderPayments_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [order_payments]
ADD CONSTRAINT FK_OrderPayments_PaymentMethod
    FOREIGN KEY ([payment_method_id]) 
    REFERENCES [payment_method] ([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [driver_review]
ADD CONSTRAINT FK_DriverReview_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [driver_review]
ADD CONSTRAINT FK_DriverReview_Driver
    FOREIGN KEY ([driver_id]) 
    REFERENCES [driver] ([driver_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; 

ALTER TABLE [driver_review]
ADD CONSTRAINT FK_DriverReview_Customer
    FOREIGN KEY ([customer_id]) 
    REFERENCES [customer] ([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION; -- prevent cascading loop

ALTER TABLE [promotion]
ADD CONSTRAINT FK_Promotion_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [delivery_fee_discount]
ADD CONSTRAINT FK_DeliveryFeeDiscount_Promotion
    FOREIGN KEY ([promotion_id]) 
    REFERENCES [promotion] ([promotion_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [percentage_discount]
ADD CONSTRAINT FK_PercentageDiscount_Promotion
    FOREIGN KEY ([promotion_id]) 
    REFERENCES [promotion] ([promotion_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [fixed_amount_discount]
ADD CONSTRAINT FK_FixedAmountDiscount_Promotion
    FOREIGN KEY ([promotion_id]) 
    REFERENCES [promotion] ([promotion_id]) ON DELETE CASCADE ON UPDATE CASCADE;
    
ALTER TABLE [support_request]
ADD CONSTRAINT FK_SupportRequest_User
    FOREIGN KEY ([user_id])
    REFERENCES [user] ([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [support_request]
ADD CONSTRAINT FK_SupportRequest_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE [support_request]
ADD CONSTRAINT FK_SupportRequest_Administrator
    FOREIGN KEY ([administrator_username]) 
    REFERENCES [administrator] ([username]) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE [notification]
ADD CONSTRAINT FK_Notification_User
    FOREIGN KEY ([user_id]) 
    REFERENCES [user] ([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE [notification]
ADD CONSTRAINT FK_Notification_Order
    FOREIGN KEY ([order_id]) 
    REFERENCES [order] ([order_id]) ON DELETE SET NULL ON UPDATE CASCADE;