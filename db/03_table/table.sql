-- ===================================================
-- File: 01_tables.sql
-- Purpose: Defines all base tables for the database.
-- Notes:
-- - No constraints or foreign keys are defined IN this file.
-- - Tables are created IN dependency-safe order.
-- ===================================================

CREATE TABLE [user]
    (
        [user_id]           	IDType      	PRIMARY KEY,
        [name]              	NVARCHAR(128) 	NOT NULL,
        [email]             	VARCHAR(64) 	UNIQUE,	
        [password_hash]         VARCHAR(64) 	NOT NULL,
        [phone]             	VARCHAR(16)     NULL,
        -- [role]              	VARCHAR(32) 	NOT NULL, -- Eliminate to ensure normalization
        [registration_date] 	DATE        	NOT NULL
    )

CREATE TABLE [customer]
    (
        [customer_id]               IDType      PRIMARY KEY,
        [recommended_customer_id]   IDType      NULL,
    )

CREATE TABLE [driver]
    (
        [driver_id]         	IDType       	PRIMARY KEY,
        [driver_license_id] 	VARCHAR(64)     NOT NULL,	
        [status]            	VARCHAR(32) 	NOT NULL
            DEFAULT 'OFFLINE',
    )

CREATE TABLE [vehicle]
    (
        [vehicle_id]    	IDType       	PRIMARY KEY,
        [vehicle_color] 	NVARCHAR(32)  	NOT NULL,
        [model]         	VARCHAR(32) 	NOT NULL,
        [license_plate] 	VARCHAR(32)     NULL,
        [driver_id]     	IDType          NOT NULL,
    )

CREATE TABLE [restaurant_owner]
	(
		[owner_id]      IDType      PRIMARY KEY
	)

CREATE TABLE [delivery_address]
	(
		[address_id]   		IDType 			NOT NULL,
		[customer_id]  		IDType 			NOT NULL,
		[recipient_name] 	NVARCHAR(128) 	NOT NULL,
		[phone]          	VARCHAR(16)		NOT NULL,
		[longitude]     	LongitudeType 	NOT NULL,
		[latitude]      	LatitudeType  	NOT NULL,
		[details]       	NVARCHAR(256)   NOT NULL
	)

CREATE TABLE [payment_method]
	(
		[payment_id]  	IDType       	PRIMARY KEY,
		[customer_id] 	IDType       	NOT NULL,
		-- [type]        	VARCHAR(32) 	NOT NULL, -- Eliminate to ensure normalization
	)

CREATE TABLE [e_wallet]
	(
		[e_wallet_id] 	IDType      	PRIMARY KEY,
		[provider]    	VARCHAR(64) 	NOT NULL,
		[wallet_number] VARCHAR(32) 	NOT NULL
	)

CREATE TABLE [bank_card]
	(
		[bank_card_id] 	IDType      	PRIMARY KEY,
		[bank_name]   	VARCHAR(64) 	NOT NULL,
		[card_number] 	VARCHAR(32) 	NOT NULL,
		[expiry_date] 	DATE        	NOT NULL
	)

CREATE TABLE [cash]
	(
		[cash_id] IDType PRIMARY KEY
	)

CREATE TABLE [restaurant]
	(
		[restaurant_id] 	IDType 			PRIMARY KEY,
  		[owner_id] 			IDType          NOT NULL, -- Có cần not null không?
  		[name] 				NVARCHAR(128) 	NOT NULL,
  		[phone] 			VARCHAR(16)     NULL,
  		[email] 			VARCHAR(64)     NULL,
  		[address_details] 	NVARCHAR(256)   NULL,
  		[longitude] 		LongitudeType   NULL,
  		[latitude] 			LatitudeType    NULL,
  		[registration_date] DATE 			NOT NULL,
  		[status] 			VARCHAR(32) 	NOT NULL 
            DEFAULT 'CLOSED',
	)

CREATE TABLE [operating_hour] 
	(
  		[restaurant_id] 	IDType 		NOT NULL,
  		[dow] 				TINYINT 	NOT NULL,
  		[open_time] 		TIME 		NOT NULL,
  		[close_time] 		TIME,
	)

CREATE TABLE [menu_item]
	(
		[food_id]       	IDType       	NOT NULL,
		[restaurant_id] 	IDType       	NOT NULL,
		[name]          	NVARCHAR(128) 	NOT NULL,
		[description]   	NVARCHAR(512)   NULL,
		[price]         	MoneyType		NOT NULL,
		[status]        	VARCHAR(32)  	NOT NULL
            DEFAULT 'UNAVAILABLE',
        [sold]         	    INT         	NOT NULL
            DEFAULT 0,
        [favourites]       INT         	NOT NULL
            DEFAULT 0,
	)

CREATE TABLE [menu_item_favourite]
	(
		[customer_id]  		IDType 		NOT NULL,
		[restaurant_id] 	IDType 		NOT NULL,
		[menu_item_id] 		IDType 		NOT NULL,
		[favorited_at] 		DATE 		NOT NULL,
	)

CREATE TABLE [restaurant_review]
	(
		[order_id]     		IDType       	PRIMARY KEY,
		[restaurant_id] 	IDType    	    NULL,
		[customer_id]   	IDType          NULL,
		[rating_point]     	INT          	NOT NULL,
		[comment]       	NVARCHAR(1024)  NULL,
		[created_at]   		DATE         	NOT NULL
	)

CREATE TABLE [category]
	(
		[name]         	NVARCHAR(64) 	PRIMARY KEY,
	)

CREATE TABLE [category_items]
	(
		[category_name] 	NVARCHAR(64) 	NOT NULL,
		[restaurant_id]  	IDType       	NOT NULL,
		[menu_item_id]  	IDType       	NOT NULL,
	)

CREATE TABLE [order]
    (
        [order_id]      	IDType        	PRIMARY KEY,
        [customer_id]   	IDType        	NOT NULL,
        [driver_id]     	IDType          NULL,	
        [restaurant_id] 	IDType        	NOT NULL,
        [delivery_id]   	IDType          NOT NULL,	 -- if order is IN CART, delivery_id should be the default address
        [status]        	VARCHAR(32)   	NOT NULL
            DEFAULT 'IN_CART',
        [customer_note] 	NVARCHAR(1024)  NULL,
        [delivery_fee]  	MoneyType       NULL,
        [ordered_at]    	DATETIME        NULL,
        [delivered_at]  	DATETIME        NULL
    )

CREATE TABLE [order_items]
    (
        [order_id]      	IDType 		        NOT NULL,
        [restaurant_id] 	IDType              NOT NULL, 
        [item_id]       	IDType              NOT NULL, 
        [quantity]      	INT    		        NOT NULL
            DEFAULT 1,	
        [price]         	MoneyType           NULL, -- price at the time of order
        [note]          	NVARCHAR(1024)      NULL,
    )

CREATE TABLE [order_payments]
    (
        [order_payment_id]  IDType      NOT NULL,
        [order_id]          IDType      NOT NULL,
        [payment_method_id] IDType      NOT NULL,
        [status]            VARCHAR(32) NOT NULL,
        [paid_at]           DATETIME    NULL,
        [created_at]        DATETIME    NOT NULL,
    )

CREATE TABLE [driver_review]
    (
        [order_id]     		IDType       	PRIMARY KEY,
        [driver_id]    		IDType          NULL,	
        [customer_id]  		IDType       	NULL,	
        [rating_point] 		INT          	NOT NULL,
        [comment]      		NVARCHAR(1024)  NULL,
        [created_at]   		DATE         	NOT NULL
    )

CREATE TABLE [promotion]
    (
        [promotion_id]    	IDType        	PRIMARY KEY,
        [order_id]        	IDType          NULL,
        -- [type]            	VARCHAR(32)  	NOT NULL, -- Eliminate to ensure normalization
        [min_order_value] 	MoneyType 		NOT NULL,
        [start_date]      	DATE            NULL,
        [end_date]        	DATE            NULL
    )

CREATE TABLE [delivery_fee_discount]
    (
        [promotion_id]         	IDType 		PRIMARY KEY,
        [ship_discount_amount] 	MoneyType 	NOT NULL
    )

CREATE TABLE [percentage_discount]
    (
        [promotion_id]        	IDType 		PRIMARY KEY,
        [discount_percent]    	INT         NOT NULL,
        [max_discount_amount] 	MoneyType   NULL
    )

CREATE TABLE [fixed_amount_discount]
    (
        [promotion_id]          IDType      PRIMARY KEY,
        [fixed_discount_amount] MoneyType 	NOT NULL
    )

CREATE TABLE [support_request]
    (
        [support_id]                BIGINT IDENTITY(1,1)   PRIMARY KEY,  -- auto-increment
        [user_id]                	IDType        	NOT NULL,
        [order_id]               	IDType          NULL,	
        [administrator_username] 	VARCHAR(128)    NULL,	
        [issue_type]             	VARCHAR(32)   	NOT NULL
            DEFAULT 'OTHER',
        [description]            	NVARCHAR(2048) 	NOT NULL,
        [status]                 	VARCHAR(32)   	NOT NULL,
        [created_at]             	DATE          	NOT NULL
    )

CREATE TABLE [administrator]
    (
        [username] 	        VARCHAR(128) 	PRIMARY KEY,
        [password_hash] 	VARCHAR(64) 	NOT NULL
    )

CREATE TABLE [notification]
    (
        [notification_id] 	BIGINT IDENTITY(1,1)   PRIMARY KEY,  -- auto-increment
        [user_id]         	IDType       	NOT NULL,
        [order_id]        	IDType       	NOT NULL,
        [type]            	VARCHAR(32) 	NOT NULL,
        [message]         	NVARCHAR(1024)  NOT NULL,
        [sent_at]         	DATETIME        NOT NULL,
        [is_read]         	BIT      	    NOT NULL
            DEFAULT 0,
    )