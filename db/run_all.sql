-- =========================================
-- File: run_all.sql
-- Purpose: Runs all SQL scripts in the correct order to set up the database.
-- Note: You should run this script in SQLCMD mode.
-- =========================================


-- Step 0: Set the project root path
:setvar path "C:\Users\Admin\Source\Repos\db-sql" -- this should be set to the absolute path of the project root folder

-- Step 1: Create Database
PRINT '=============== Creating Database ===============';
:r $(path)\create_db.sql
GO


USE CrabFood;
GO

-- Step 2: Create Types
PRINT '=============== Creating Types ===============';
:r $(path)\01_type\type.sql
GO

-- Step 3: Create Sequences
PRINT '=============== Creating Sequences ===============';
:r $(path)\02_sequence\pk_sequence.sql
GO

-- Step 4: Create Tables
PRINT '=============== Creating Tables ===============';
:r $(path)\03_table\table.sql
GO

-- Step 5: Create Constraints
PRINT '=============== Creating Constraints ===============';
:r $(path)\04_constraint\ck_enum.sql
:r $(path)\04_constraint\ck_multicol.sql
:r $(path)\04_constraint\ck_pk_prefix.sql
:r $(path)\04_constraint\ck_range.sql
:r $(path)\04_constraint\pk_multicol.sql
:r $(path)\04_constraint\uq_multicol.sql
GO

-- Step 6: Create Foreign Keys
PRINT '=============== Creating Relation ===============';
:r $(path)\05_relation\relation.sql
GO

-- Step 7: Create Functions
PRINT '=============== Creating Functions ===============';
GO
:r $(path)\06_function\fn_derived_field.sql
:r $(path)\06_function\fn_get_category_restaurants.sql
:r $(path)\06_function\fn_get_incart_orders.sql
:r $(path)\06_function\fn_search_restaurants.sql
GO

-- Step 8: Create Stored Procedures
PRINT '=============== Creating Stored Procedures ===============';
GO
:r $(path)\07_procedure\sp_get_restaurant_menu.sql
:r $(path)\07_procedure\sp_insert_delivery_address.sql
:r $(path)\07_procedure\sp_insert_menu_item.sql
--:r $(path)\07_procedure\sp_insert_notification.sql
:r $(path)\07_procedure\sp_insert_order_payment.sql
:r $(path)\07_procedure\sp_insert_order.sql
:r $(path)\07_procedure\sp_insert_payment_method.sql
:r $(path)\07_procedure\sp_insert_promotion.sql
:r $(path)\07_procedure\sp_insert_restaurant.sql
--:r $(path)\07_procedure\sp_insert_support_request.sql
:r $(path)\07_procedure\sp_insert_user.sql
:r $(path)\07_procedure\sp_insert_vehicle.sql
:r $(path)\07_procedure\sp_validate_order_items.sql
GO

-- Step 9: Create Triggers
PRINT '=============== Creating Triggers ===============';
GO
:r $(path)\08_trigger\trg_business_rule.sql
:r $(path)\08_trigger\trg_derived_field.sql
GO

-- Step 10: Seed Data
PRINT '=============== Seeding Data ===============';
:r $(path)\09_data\initial_data.sql
:r $(path)\09_data\seed_data.sql
GO