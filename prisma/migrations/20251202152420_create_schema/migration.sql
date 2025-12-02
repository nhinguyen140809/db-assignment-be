BEGIN TRY

BEGIN TRAN;

-- CreateTable
CREATE TABLE [dbo].[customer] (
    [customer_id] VARCHAR(16) NOT NULL,
    [recommended_customer_id] VARCHAR(16),
    CONSTRAINT [customer_pkey] PRIMARY KEY CLUSTERED ([customer_id])
);

-- CreateTable
CREATE TABLE [dbo].[driver] (
    [driver_id] VARCHAR(16) NOT NULL,
    [vehicle_id] VARCHAR(16),
    [driver_license_id] VARCHAR(64) NOT NULL,
    [status] VARCHAR(32) NOT NULL CONSTRAINT [driver_status_df] DEFAULT 'OFFLINE',
    CONSTRAINT [driver_pkey] PRIMARY KEY CLUSTERED ([driver_id])
);

-- CreateTable
CREATE TABLE [dbo].[vehicle] (
    [vehicle_id] VARCHAR(16) NOT NULL,
    [vehicle_color] NVARCHAR(32) NOT NULL,
    [model] VARCHAR(32) NOT NULL,
    [license_plate] VARCHAR(32),
    CONSTRAINT [vehicle_pkey] PRIMARY KEY CLUSTERED ([vehicle_id])
);

-- CreateTable
CREATE TABLE [dbo].[restaurant_owner] (
    [owner_id] VARCHAR(16) NOT NULL,
    CONSTRAINT [restaurant_owner_pkey] PRIMARY KEY CLUSTERED ([owner_id])
);

-- CreateTable
CREATE TABLE [dbo].[delivery_address] (
    [address_id] VARCHAR(16) NOT NULL,
    [customer_id] VARCHAR(16) NOT NULL,
    [recipient_name] NVARCHAR(128) NOT NULL,
    [phone] VARCHAR(16) NOT NULL,
    [longitude] DECIMAL(11,8) NOT NULL,
    [latitude] DECIMAL(10,8) NOT NULL,
    [details] NVARCHAR(256) NOT NULL,
    CONSTRAINT [delivery_address_pkey] PRIMARY KEY CLUSTERED ([address_id],[customer_id])
);

-- CreateTable
CREATE TABLE [dbo].[payment_method] (
    [payment_id] VARCHAR(16) NOT NULL,
    [customer_id] VARCHAR(16) NOT NULL,
    [type] VARCHAR(32) NOT NULL,
    CONSTRAINT [payment_method_pkey] PRIMARY KEY CLUSTERED ([payment_id])
);

-- CreateTable
CREATE TABLE [dbo].[e_wallet] (
    [e_wallet_id] VARCHAR(16) NOT NULL,
    [provider] VARCHAR(64) NOT NULL,
    [wallet_number] VARCHAR(32) NOT NULL,
    CONSTRAINT [e_wallet_pkey] PRIMARY KEY CLUSTERED ([e_wallet_id])
);

-- CreateTable
CREATE TABLE [dbo].[bank_card] (
    [bank_card_id] VARCHAR(16) NOT NULL,
    [bank_name] VARCHAR(64) NOT NULL,
    [card_number] VARCHAR(32) NOT NULL,
    [expiry_date] DATE NOT NULL,
    CONSTRAINT [bank_card_pkey] PRIMARY KEY CLUSTERED ([bank_card_id])
);

-- CreateTable
CREATE TABLE [dbo].[cash] (
    [cash_id] VARCHAR(16) NOT NULL,
    CONSTRAINT [cash_pkey] PRIMARY KEY CLUSTERED ([cash_id])
);

-- CreateTable
CREATE TABLE [dbo].[restaurant] (
    [restaurant_id] VARCHAR(16) NOT NULL,
    [owner_id] VARCHAR(16),
    [name] NVARCHAR(128) NOT NULL,
    [phone] VARCHAR(16),
    [email] VARCHAR(64),
    [address_details] NVARCHAR(256),
    [longitude] DECIMAL(11,8),
    [latitude] DECIMAL(10,8),
    [registration_date] DATE NOT NULL,
    [status] VARCHAR(32) NOT NULL CONSTRAINT [restaurant_status_df] DEFAULT 'CLOSED',
    CONSTRAINT [restaurant_pkey] PRIMARY KEY CLUSTERED ([restaurant_id])
);

-- CreateTable
CREATE TABLE [dbo].[operating_hour] (
    [restaurant_id] VARCHAR(16) NOT NULL,
    [dow] TINYINT NOT NULL,
    [open_time] TIME NOT NULL,
    [close_time] TIME,
    CONSTRAINT [operating_hour_pkey] PRIMARY KEY CLUSTERED ([restaurant_id],[dow])
);

-- CreateTable
CREATE TABLE [dbo].[menu_item] (
    [food_id] VARCHAR(16) NOT NULL,
    [restaurant_id] VARCHAR(16) NOT NULL,
    [name] NVARCHAR(128) NOT NULL,
    [description] NVARCHAR(512),
    [price] DECIMAL(10,2) NOT NULL,
    [status] VARCHAR(32) NOT NULL CONSTRAINT [menu_item_status_df] DEFAULT 'UNAVAILABLE',
    CONSTRAINT [menu_item_pkey] PRIMARY KEY CLUSTERED ([restaurant_id],[food_id])
);

-- CreateTable
CREATE TABLE [dbo].[menu_item_favourite] (
    [customer_id] VARCHAR(16) NOT NULL,
    [restaurant_id] VARCHAR(16) NOT NULL,
    [menu_item_id] VARCHAR(16) NOT NULL,
    [favorited_at] DATE NOT NULL,
    CONSTRAINT [menu_item_favourite_pkey] PRIMARY KEY CLUSTERED ([customer_id],[restaurant_id],[menu_item_id])
);

-- CreateTable
CREATE TABLE [dbo].[restaurant_review] (
    [order_id] VARCHAR(16) NOT NULL,
    [restaurant_id] VARCHAR(16),
    [customer_id] VARCHAR(16),
    [rating_point] INT NOT NULL,
    [comment] NVARCHAR(1024),
    [created_at] DATE NOT NULL,
    CONSTRAINT [restaurant_review_pkey] PRIMARY KEY CLUSTERED ([order_id])
);

-- CreateTable
CREATE TABLE [dbo].[category] (
    [name] NVARCHAR(64) NOT NULL,
    CONSTRAINT [category_pkey] PRIMARY KEY CLUSTERED ([name])
);

-- CreateTable
CREATE TABLE [dbo].[category_items] (
    [category_name] NVARCHAR(64) NOT NULL,
    [restaurant_id] VARCHAR(16) NOT NULL,
    [menu_item_id] VARCHAR(16) NOT NULL,
    CONSTRAINT [category_items_pkey] PRIMARY KEY CLUSTERED ([category_name],[restaurant_id],[menu_item_id])
);

-- CreateTable
CREATE TABLE [dbo].[order] (
    [order_id] VARCHAR(16) NOT NULL,
    [customer_id] VARCHAR(16) NOT NULL,
    [driver_id] VARCHAR(16),
    [restaurant_id] VARCHAR(16) NOT NULL,
    [delivery_id] VARCHAR(16) NOT NULL,
    [status] VARCHAR(32) NOT NULL CONSTRAINT [order_status_df] DEFAULT 'IN_CART',
    [customer_note] NVARCHAR(1024),
    [delivery_fee] DECIMAL(10,2),
    [ordered_at] DATETIME,
    [delivered_at] DATETIME,
    CONSTRAINT [order_pkey] PRIMARY KEY CLUSTERED ([order_id])
);

-- CreateTable
CREATE TABLE [dbo].[order_items] (
    [order_id] VARCHAR(16) NOT NULL,
    [restaurant_id] VARCHAR(16) NOT NULL,
    [item_id] VARCHAR(16) NOT NULL,
    [quantity] INT NOT NULL CONSTRAINT [order_items_quantity_df] DEFAULT 1,
    [price] DECIMAL(10,2),
    [note] NVARCHAR(1024),
    CONSTRAINT [order_items_pkey] PRIMARY KEY CLUSTERED ([order_id],[restaurant_id],[item_id])
);

-- CreateTable
CREATE TABLE [dbo].[order_payments] (
    [order_payment_id] VARCHAR(16) NOT NULL,
    [order_id] VARCHAR(16) NOT NULL,
    [payment_method_id] VARCHAR(16) NOT NULL,
    [status] VARCHAR(32) NOT NULL,
    [paid_at] DATETIME,
    [created_at] DATETIME NOT NULL,
    CONSTRAINT [order_payments_pkey] PRIMARY KEY CLUSTERED ([order_payment_id],[order_id])
);

-- CreateTable
CREATE TABLE [dbo].[driver_review] (
    [order_id] VARCHAR(16) NOT NULL,
    [driver_id] VARCHAR(16),
    [customer_id] VARCHAR(16),
    [rating_point] INT NOT NULL,
    [comment] NVARCHAR(1024),
    [created_at] DATE NOT NULL,
    CONSTRAINT [driver_review_pkey] PRIMARY KEY CLUSTERED ([order_id])
);

-- AddForeignKey
ALTER TABLE [dbo].[customer] ADD CONSTRAINT [customer_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[user]([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[customer] ADD CONSTRAINT [customer_recommended_customer_id_fkey] FOREIGN KEY ([recommended_customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[driver] ADD CONSTRAINT [driver_driver_id_fkey] FOREIGN KEY ([driver_id]) REFERENCES [dbo].[user]([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[driver] ADD CONSTRAINT [driver_vehicle_id_fkey] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicle]([vehicle_id]) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[restaurant_owner] ADD CONSTRAINT [restaurant_owner_owner_id_fkey] FOREIGN KEY ([owner_id]) REFERENCES [dbo].[user]([user_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[delivery_address] ADD CONSTRAINT [delivery_address_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[payment_method] ADD CONSTRAINT [payment_method_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[e_wallet] ADD CONSTRAINT [e_wallet_e_wallet_id_fkey] FOREIGN KEY ([e_wallet_id]) REFERENCES [dbo].[payment_method]([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[bank_card] ADD CONSTRAINT [bank_card_bank_card_id_fkey] FOREIGN KEY ([bank_card_id]) REFERENCES [dbo].[payment_method]([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[cash] ADD CONSTRAINT [cash_cash_id_fkey] FOREIGN KEY ([cash_id]) REFERENCES [dbo].[payment_method]([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[restaurant] ADD CONSTRAINT [restaurant_owner_id_fkey] FOREIGN KEY ([owner_id]) REFERENCES [dbo].[restaurant_owner]([owner_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[operating_hour] ADD CONSTRAINT [operating_hour_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[menu_item] ADD CONSTRAINT [menu_item_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[menu_item_favourite] ADD CONSTRAINT [menu_item_favourite_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[menu_item_favourite] ADD CONSTRAINT [menu_item_favourite_restaurant_id_menu_item_id_fkey] FOREIGN KEY ([restaurant_id], [menu_item_id]) REFERENCES [dbo].[menu_item]([restaurant_id],[food_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[menu_item_favourite] ADD CONSTRAINT [menu_item_favourite_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[restaurant_review] ADD CONSTRAINT [restaurant_review_order_id_fkey] FOREIGN KEY ([order_id]) REFERENCES [dbo].[order]([order_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[restaurant_review] ADD CONSTRAINT [restaurant_review_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[restaurant_review] ADD CONSTRAINT [restaurant_review_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[category_items] ADD CONSTRAINT [category_items_category_name_fkey] FOREIGN KEY ([category_name]) REFERENCES [dbo].[category]([name]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[category_items] ADD CONSTRAINT [category_items_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[category_items] ADD CONSTRAINT [category_items_restaurant_id_menu_item_id_fkey] FOREIGN KEY ([restaurant_id], [menu_item_id]) REFERENCES [dbo].[menu_item]([restaurant_id],[food_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[order] ADD CONSTRAINT [order_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[order] ADD CONSTRAINT [order_driver_id_fkey] FOREIGN KEY ([driver_id]) REFERENCES [dbo].[driver]([driver_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[order] ADD CONSTRAINT [order_restaurant_id_fkey] FOREIGN KEY ([restaurant_id]) REFERENCES [dbo].[restaurant]([restaurant_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[order] ADD CONSTRAINT [order_delivery_id_customer_id_fkey] FOREIGN KEY ([delivery_id], [customer_id]) REFERENCES [dbo].[delivery_address]([address_id],[customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[order_items] ADD CONSTRAINT [order_items_order_id_fkey] FOREIGN KEY ([order_id]) REFERENCES [dbo].[order]([order_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[order_items] ADD CONSTRAINT [order_items_restaurant_id_item_id_fkey] FOREIGN KEY ([restaurant_id], [item_id]) REFERENCES [dbo].[menu_item]([restaurant_id],[food_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[order_payments] ADD CONSTRAINT [order_payments_order_id_fkey] FOREIGN KEY ([order_id]) REFERENCES [dbo].[order]([order_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[order_payments] ADD CONSTRAINT [order_payments_payment_method_id_fkey] FOREIGN KEY ([payment_method_id]) REFERENCES [dbo].[payment_method]([payment_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[driver_review] ADD CONSTRAINT [driver_review_order_id_fkey] FOREIGN KEY ([order_id]) REFERENCES [dbo].[order]([order_id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[driver_review] ADD CONSTRAINT [driver_review_driver_id_fkey] FOREIGN KEY ([driver_id]) REFERENCES [dbo].[driver]([driver_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[driver_review] ADD CONSTRAINT [driver_review_customer_id_fkey] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer]([customer_id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH
