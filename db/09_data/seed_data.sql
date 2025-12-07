-- ===================================================
-- File: seed_data.sql
-- Purpose: Insert sample data
-- ===================================================


-- ==================================================
-- SAMPLE CUSTOMERS
-- ==================================================
EXEC sp_InsertCustomer
    @Name = 'John Doe',
    @Email = 'john.doe@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123 
    @RegistrationDate = '2024-01-15';

EXEC sp_InsertCustomer
    @Name = 'Jane Smith',
    @Email = 'jane.smith@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @RecommendedCustomerID = 'USR0000000000001';                                    -- assuming this is John Doe's ID

EXEC sp_InsertCustomer
    @Name = 'Alice Johnson',
    @Email = 'alice.johnson@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0112233445',
    @RegistrationDate = '2024-02-20';

EXEC sp_InsertCustomer
    @Name = 'Bob Brown',
    @Email = 'bob.brown@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0556677889',
    @RecommendedCustomerID = 'USR0000000000003';                                    -- assuming this is Alice Johnson's ID

EXEC sp_InsertCustomer
    @Name = 'Charlie Davis',
    @Email = 'charlie.davis@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0223344556',
    @RegistrationDate = '2024-03-10';

EXEC sp_InsertCustomer
    @Name = 'Frank Green',
    @Email = 'frank.green@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @RecommendedCustomerID = 'USR0000000000003';                                    -- assuming this is Alice Johnson's ID

EXEC sp_InsertCustomer
    @Name = 'Grace Harris',
    @Email = 'grace.harris@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0556677889',
    @RecommendedCustomerID = 'USR0000000000003';                                    -- assuming this is Bob Brown's ID

-- ==================================================
-- SAMPLE DRIVERS
-- ==================================================

EXEC sp_InsertDriver
    @Name = 'David Wilson',
    @Email = 'david.wilson@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0667788990',
    @DriverLicenseID = 'D1234567',
    @Status = 'ONLINE';

EXEC sp_InsertDriver
    @Name = 'Eva Martinez',
    @Email = 'eva.martinez@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0778899001',
    @DriverLicenseID = 'D2345678',
    @Status = 'BUSY';

EXEC sp_InsertDriver
    @Name = 'Frank Thomas',
    @Email = 'frank.thomas@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0889900112',
    @DriverLicenseID = 'D3456789',
    @Status = 'ONLINE';

EXEC sp_InsertDriver
    @Name = 'Hannah Lee',
    @Email = 'hannah.lee@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '0990011223',
    @DriverLicenseID = 'D4567890',
    @Status = 'ONLINE';

EXEC sp_InsertDriver
    @Name = 'Ian Walker',
    @Email = 'ian.walker@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '1001122334',
    @DriverLicenseID = 'D5678901',
    @Status = 'ONLINE';

EXEC sp_InsertDriver
    @Name = 'Julia Hall',
    @Email = 'julia.hall@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '1112233445',
    @DriverLicenseID = 'D6789012';

-- ==================================================
-- SAMPLE VEHICLES
-- ==================================================

EXEC sp_InsertVehicle
    @VehicleColor = 'Red',
    @Model = 'Honda SH',
    @LicensePlate = '29A-12345',
    @DriverID = 'USR0000000000008'; 

EXEC sp_InsertVehicle
    @VehicleColor = 'Blue',
    @Model = 'Yamaha NVX',
    @LicensePlate = '30B-67890',
    @DriverID = 'USR0000000000009';

EXEC sp_InsertVehicle
    @VehicleColor = 'Black',
    @Model = 'Piaggio Liberty',
    @LicensePlate = '31C-54321',
    @DriverID = 'USR0000000000010';

EXEC sp_InsertVehicle
    @VehicleColor = 'White',
    @Model = 'Honda Air Blade',
    @LicensePlate = '32D-98765',
    @DriverID = 'USR0000000000011';

EXEC sp_InsertVehicle
    @VehicleColor = 'Green',
    @Model = 'Yamaha Grande',
    @LicensePlate = '33E-11223',
    @DriverID = 'USR0000000000012';

EXEC sp_InsertVehicle
    @VehicleColor = 'Yellow',
    @Model = 'Honda Wave',
    @LicensePlate = '34F-44556',
    @DriverID = 'USR0000000000013';

-- ==================================================
-- SAMPLE RESTAURANT OWNERS
-- ==================================================
EXEC sp_InsertRestaurantOwner
    @Name = 'Karen Young',
    @Email = 'karen.young@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '1223344556';

EXEC sp_InsertRestaurantOwner
    @Name = 'Larry King',
    @Email = 'larry.king@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a', -- hashed password 123
    @Phone = '1334455667';

EXEC sp_InsertRestaurantOwner
    @Name = 'Michael Scott',
    @Email = 'michael.scott@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'; -- hashed password 123

EXEC sp_InsertRestaurantOwner
    @Name = 'Nina Patel',
    @Email = 'nina.patel@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'; -- hashed password 123

EXEC sp_InsertRestaurantOwner
    @Name = 'Oscar Ramirez',
    @Email = 'oscar.ramirez@example.com',
    @PasswordHash = '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'; -- hashed password 123

-- ==================================================
-- SAMPLE RESTAURANTS
-- ==================================================

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000014', -- ID of Karen Young
    @Name = 'Gourmet Bites',
    @AddressDetails = '123 Food St, Flavor Town',
    @Phone = '1445566778',
    @Longitude = 106.6297,
    @Latitude = 10.8231,
    @Status = 'OPEN';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000014', -- ID of Karen Young
    @Name = 'Pizza Palace',
    @AddressDetails = '456 Cheese Ave, Slice City',
    @Phone = '1556677889',
    @Longitude = 106.7000,
    @Latitude = 10.7800,
    @Status = 'OPEN';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000015', -- ID of Larry King
    @Name = 'Sushi World';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000016', -- ID of Michael Scott
    @Name = 'Taco Town',
    @AddressDetails = '789 Spice Rd, Zesty Ville',
    @Longitude = 106.6800,
    @Latitude = 10.7900,
    @Status = 'OPEN';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000017', -- ID of Nina Patel
    @Name = 'Curry Corner',
    @AddressDetails = '321 Heat St, Flavor Town',
    @Phone = '1667788990',
    @Longitude = 106.6400,
    @Latitude = 10.8100,
    @Status = 'OPEN';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000017', -- ID of Nina Patel
    @Name = 'Burger Barn',
    @AddressDetails = '654 Grill Ave, Patty City',
    @Longitude = 106.6600,
    @Latitude = 10.8000,
    @Status = 'OPEN';

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000014', -- ID of Karen Young
    @Name = 'Pasta Place',
    @AddressDetails = '987 Noodle Rd, Carb Town',
    @Phone = '1778899001',
    @Longitude = 106.6900,
    @Latitude = 10.7700;

EXEC sp_InsertRestaurant
    @OwnerID = 'USR0000000000015', -- ID of Larry King
    @Name = 'Salad Stop',
    @AddressDetails = '159 Green St, Fresh City',
    @Phone = '1889900112',
    @Longitude = 106.6500,
    @Latitude = 10.8200,
    @Status = 'UNAVAILABLE';

-- ==================================================
-- SAMPLE DELIVERY ADDRESSES
-- ==================================================

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000001', -- assuming this is John Doe's ID
    @RecipientName = 'John Doe',
    @Phone = '0998877665',
    @Details = '12 Elm St, Hometown',
    @Longitude = 106.6270,
    @Latitude = 10.8235;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000002', -- assuming this is Jane Smith
    @RecipientName = 'Jane Smith',
    @Phone = '0887766554',
    @Details = '34 Oak St, Hometown',
    @Longitude = 106.6280,
    @Latitude = 10.8240;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000002', -- assuming this is Alice Johnson
    @RecipientName = 'Alice Johnson',
    @Phone = '0776655443',
    @Details = '56 Pine St, Hometown',
    @Longitude = 106.6290,
    @Latitude = 10.8250;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000002', -- assuming this is Bob Brown
    @RecipientName = 'Bob Brown',
    @Phone = '0665544332',
    @Details = '78 Maple St, Hometown',
    @Longitude = 106.6300,
    @Latitude = 10.8260;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000005', -- assuming this is Charlie Davis
    @RecipientName = 'Charlie Davis',
    @Phone = '0554433221',
    @Details = '90 Birch St, Hometown',
    @Longitude = 106.6310,
    @Latitude = 10.8270;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000003', -- assuming this is Frank Green
    @RecipientName = 'Frank Green',
    @Phone = '0443322110',
    @Details = '11 Cedar St, Hometown',
    @Longitude = 106.6320,
    @Latitude = 10.8280;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000004', -- assuming this is Grace Harris
    @RecipientName = 'Grace Harris',
    @Phone = '0332211009',
    @Details = '22 Spruce St, Hometown',
    @Longitude = 106.6330,
    @Latitude = 10.8290;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000001', -- assuming this is John Doe's ID
    @RecipientName = 'John Doe',
    @Phone = '0998877665',
    @Details = '99 Walnut St, Hometown',
    @Longitude = 106.6340,
    @Latitude = 10.8300;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000006', -- assuming this is Jane Smith
    @RecipientName = 'Jane Smith',
    @Phone = '0887766554',
    @Details = '88 Chestnut St, Hometown',
    @Longitude = 106.6350,
    @Latitude = 10.8310;

EXEC sp_InsertDeliveryAddress
    @CustomerID = 'USR0000000000007', -- assuming this is Charlie Davis
    @RecipientName = 'Charlie Davis',
    @Phone = '0554433221',
    @Details = '77 Poplar St, Hometown',
    @Longitude = 106.6360,
    @Latitude = 10.8320;

-- ==================================================
-- SAMPLE PAYMENT METHODS
-- ==================================================

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000001', -- John Doe
    @Type = 'BANK_CARD',
    @BankName = 'Bank A',
    @CardNumber = '4111111111111111',
    @ExpiryDate = '2025-12-31';

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000002', -- Jane Smith
    @Type = 'E_WALLET',
    @Provider = 'E-Wallet X',
    @WalletNumber = 'EW123456789';

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000003', -- Alice Johnson
    @Type = 'CASH';

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000004', -- Bob Brown
    @Type = 'BANK_CARD',
    @BankName = 'Bank B',
    @CardNumber = '5500000000000004',
    @ExpiryDate = '2026-11-30';

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000005', -- Charlie Davis
    @Type = 'E_WALLET',
    @Provider = 'E-Wallet Y',
    @WalletNumber = 'EW987654321';

EXEC sp_InsertPaymentMethod
    @CustomerID = 'USR0000000000001', 
    @Type = 'E_WALLET',
    @Provider = 'E-Wallet Z',
    @WalletNumber = 'EW112233445';

-- ===============================================
-- SAMPLE OPERATING HOURS
-- ===============================================

INSERT INTO [operating_hour] (restaurant_id, dow, open_time, close_time)
VALUES
    ('RES0000000000001', 0, '09:00', '21:00'),
    ('RES0000000000001', 1, '09:00', '21:00'),
    ('RES0000000000001', 2, '09:00', '21:00'),
    ('RES0000000000001', 3, '09:00', '21:00'),
    ('RES0000000000001', 4, '09:00', '22:00'),
    ('RES0000000000001', 5, '10:00', '22:00'),
    ('RES0000000000001', 6, '10:00', '20:00'),
    ('RES0000000000002', 1, '10:00', '22:00'),
    ('RES0000000000002', 2, '10:00', '22:00'),
    ('RES0000000000002', 3, '10:00', '22:00'),
    ('RES0000000000002', 4, '10:00', '22:00'),
    ('RES0000000000002', 0, '10:00', '22:00'),
    ('RES0000000000003', 4, '11:00', '23:00'),
    ('RES0000000000003', 5, '11:00', '23:00'),
    ('RES0000000000003', 6, '12:00', '20:00'),
    ('RES0000000000004', 3, '10:00', '22:00'),
    ('RES0000000000004', 4, '10:00', '22:00');

-- ===============================================
-- SAMPLE MENU ITEMS
-- ===============================================

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @Name = 'Grilled Chicken Salad',
    @Description = 'Fresh salad with grilled chicken, mixed greens, and vinaigrette dressing.',
    @Price = 9.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @Name = 'Veggie Wrap',
    @Description = 'Whole wheat wrap filled with fresh vegetables and hummus.',
    @Price = 7.49,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @Name = 'Fruit Smoothie',
    @Description = 'Blend of fresh fruits and yogurt.',
    @Price = 4.99,
    @Status = 'UNAVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @Name = 'Quinoa Bowl',
    @Description = 'Quinoa with roasted vegetables and a lemon-tahini dressing.',
    @Price = 8.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @Name = 'Avocado Toast',
    @Description = 'Toasted bread topped with mashed avocado, cherry tomatoes, and a sprinkle of feta cheese.',
    @Price = 6.49,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @Name = 'Margherita Pizza',
    @Description = 'Classic pizza with fresh mozzarella, tomatoes, and basil.',
    @Price = 12.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @Name = 'Pepperoni Pizza',
    @Description = 'Pizza topped with pepperoni slices and mozzarella cheese.',
    @Price = 14.49,
    @Status = 'DELETED';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @Name = 'Veggie Pizza',
    @Description = 'Pizza loaded with bell peppers, onions, mushrooms, and olives.',
    @Price = 13.99,
    @Status = 'UNAVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @Name = 'BBQ Chicken Pizza',
    @Description = 'Pizza with BBQ sauce, grilled chicken, red onions, and cilantro.',
    @Price = 15.49,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @Name = 'Hawaiian Pizza',
    @Description = 'Pizza topped with ham and pineapple chunks.',
    @Price = 14.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @Name = 'California Roll',
    @Description = 'Crab, avocado, and cucumber roll topped with sesame seeds.',
    @Price = 8.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @Name = 'Spicy Tuna Roll',
    @Description = 'Tuna mixed with spicy mayo, rolled with cucumber and seaweed.',
    @Price = 9.49,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @Name = 'Vegetable Roll',
    @Description = 'Assorted fresh vegetables rolled in rice and seaweed.',
    @Price = 7.99,
    @Status = 'UNAVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @Name = 'Salmon Nigiri',
    @Description = 'Fresh salmon slices over vinegared rice.',
    @Price = 10.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @Name = 'Tempura Udon',
    @Description = 'Udon noodles in broth topped with tempura shrimp and vegetables.',
    @Price = 11.49,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000004', -- Taco Town
    @Name = 'Beef Taco',
    @Description = 'Soft taco filled with seasoned beef, lettuce, cheese, and salsa.',
    @Price = 3.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000004', -- Taco Town
    @Name = 'Chicken Taco',
    @Description = 'Soft taco filled with grilled chicken, lettuce, cheese, and pico de gallo.',
    @Price = 4.49,
    @Status = 'DELETED';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000004', -- Taco Town
    @Name = 'Fish Taco',
    @Description = 'Soft taco filled with battered fish, cabbage slaw, and creamy sauce.',
    @Price = 4.99,
    @Status = 'AVAILABLE';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000004', -- Taco Town
    @Name = 'Veggie Taco',
    @Description = 'Soft taco filled with grilled vegetables, lettuce, and salsa.',
    @Price = 3.99,
    @Status = 'DELETED';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000006', -- Pasta Place
    @Name = 'Spaghetti Bolognese',
    @Description = 'Classic spaghetti with rich meat sauce.',
    @Price = 11.99,
    @Status = 'DELETED';

EXEC sp_InsertMenuItem
    @RestaurantID = 'RES0000000000006', -- Pasta Place
    @Name = 'Fettuccine Alfredo',
    @Description = 'Fettuccine pasta in creamy Alfredo sauce.',
    @Price = 12.49,
    @Status = 'AVAILABLE';

-- ===============================================
-- SAMPLE MENU ITEM FAVORITES
-- ===============================================

INSERT INTO [menu_item_favourite]
    (
        customer_id,
        restaurant_id,
        menu_item_id,
        favorited_at
    )
VALUES
    (
        'USR0000000000001', 'RES0000000000001', 'FOO0000000000001', '2024-06-20'
    ), -- John Doe favorites Grilled Chicken Salad
    (
        'USR0000000000002', 'RES0000000000002', 'FOO0000000000002', '2024-06-21'
    ), -- Jane Smith favorites Pepperoni Pizza
    (
        'USR0000000000003', 'RES0000000000003', 'FOO0000000000005', '2024-06-22'
    ), -- Alice Johnson favorites Vegetable Roll
    (
        'USR0000000000004', 'RES0000000000001', 'FOO0000000000004', '2024-06-23'
    ), -- Bob Brown favorites Veggie Wrap
    (
        'USR0000000000005', 'RES0000000000002', 'FOO0000000000005', '2024-06-24'
    ), -- Charlie Davis favorites Hawaiian Pizza
    (
        'USR0000000000001', 'RES0000000000003', 'FOO0000000000005', '2024-06-25'
    ), -- John Doe favorites Tempura Udon
    (
        'USR0000000000002', 'RES0000000000004', 'FOO0000000000001', '2024-06-26'
    ), -- Jane Smith favorites Beef Taco
    (
        'USR0000000000003', 'RES0000000000001', 'FOO0000000000001', '2024-06-27'
    ), -- Alice Johnson favorites Grilled Chicken Salad
    (
        'USR0000000000004', 'RES0000000000002', 'FOO0000000000002', '2024-06-28'
    ), -- Bob Brown favorites Pepperoni Pizza
    (
        'USR0000000000005', 'RES0000000000003', 'FOO0000000000003', '2024-06-29'
    ), -- Charlie Davis favorites Vegetable Roll
    (
        'USR0000000000001', 'RES0000000000004', 'FOO0000000000003', '2024-06-30'
    ), -- John Doe favorites Fish Taco
    (
        'USR0000000000002', 'RES0000000000006', 'FOO0000000000001', '2024-07-01'
    ), -- Jane Smith favorites Spaghetti Bolognese
    (
        'USR0000000000003', 'RES0000000000006', 'FOO0000000000002', '2024-07-02'
    ), -- Alice Johnson favorites Fettuccine Alfredo
    (
        'USR0000000000004', 'RES0000000000001', 'FOO0000000000005', '2024-07-03'
    ), -- Bob Brown favorites Avocado Toast
    (
        'USR0000000000005', 'RES0000000000002', 'FOO0000000000004', '2024-07-04'
    ); -- Charlie Davis favorites Veggie Pizza

-- ===============================================
-- SAMPLE ORDERS AND ORDER ITEMS
-- ===============================================

EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000001',        -- John Doe
    @RestaurantID = 'RES0000000000001',      -- Gourmet Bites
    @DeliveryAddressID = 'ADR0000000000001', -- John's delivery address
    @DriverID = 'USR0000000000008',          -- David Wilson
    @CustomerNote = 'Please leave at the door.',
    @DeliveryFee = 2.50,
    @OrderedAt = '2024-06-20 12:30:00';

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000001', 'RES0000000000001', 'FOO0000000000001', 2, 9.99, 'No dressing'
    ), -- 2 Grilled Chicken Salads
    (
        'ORD0000000000001', 'RES0000000000001', 'FOO0000000000004', 1, 8.99, NULL
    ); -- 1 Quinoa Bowl

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000002',        -- Jane Smith
    @RestaurantID = 'RES0000000000002',      -- Pizza Palace
    @DeliveryAddressID = 'ADR0000000000002', -- Jane's delivery address
    @DriverID = 'USR0000000000008',          -- Eva Martinez
    @CustomerNote = 'Extra napkins, please.',
    @DeliveryFee = 3.00,
    @OrderedAt = '2024-06-21 18:45:00';

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000002', 'RES0000000000002', 'FOO0000000000002', 1, 12.99, 'Extra cheese'
    ), -- 1 Margherita Pizza
    (
        'ORD0000000000002', 'RES0000000000002', 'FOO0000000000005', 1, 14.49, NULL
    ), -- 1 Pepperoni Pizza
    (
        'ORD0000000000002', 'RES0000000000002', 'FOO0000000000004', 2, 13.99, 'No olives'
    ); -- 2 Veggie Pizzas

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000003',        -- Alice Johnson
    @RestaurantID = 'RES0000000000003',      -- Sushi World
    @DeliveryAddressID = 'ADR0000000000001', -- Alice's delivery address
    @CustomerNote = 'No wasabi, please.',
    @DeliveryFee = 2.75,
    @OrderedAt = '2024-06-22 13:15:00';

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000003', 'RES0000000000003', 'FOO0000000000003', 3, 8.99, NULL
    ), -- 3 California Rolls
    (
        'ORD0000000000003', 'RES0000000000003', 'FOO0000000000004', 1, 10.99, NULL
    ), -- 1 Salmon Nigiri
    (
        'ORD0000000000003', 'RES0000000000003', 'FOO0000000000005', 2, 9.49, NULL
    ); -- 2 Spicy Tuna Rolls

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000004',        -- Bob Brown
    @RestaurantID = 'RES0000000000001',      -- Gourmet Bites
    @DeliveryAddressID = 'ADR0000000000001', -- Bob's delivery address
    @DriverID = 'USR0000000000009',          -- Frank Thomas
    @CustomerNote = 'Please call when you arrive.',
    @DeliveryFee = 2.50,
    @OrderedAt = '2024-06-23 11:00:00';

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000004', 'RES0000000000001', 'FOO0000000000004', 1, 8.99, NULL
    ), -- 1 Quinoa Bowl
    (
        'ORD0000000000004', 'RES0000000000001', 'FOO0000000000005', 2, 6.49, NULL
    ); -- 2 Avocado Toasts

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000005',        -- Charlie Davis
    @RestaurantID = 'RES0000000000002',      -- Pizza Palace
    @DeliveryAddressID = 'ADR0000000000001', -- Charlie's delivery address
    @DriverID = 'USR0000000000010',          -- Hannah Lee
    @CustomerNote = 'Gluten-free crust, please.',
    @DeliveryFee = 3.00,
    @OrderedAt = '2024-06-24 19:30:00';

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000005', 'RES0000000000002', 'FOO0000000000002', 1, 12.99, NULL
    ), -- 1 Margherita Pizza
    (
        'ORD0000000000005', 'RES0000000000002', 'FOO0000000000003', 1, 13.99, NULL
    ); -- 1 Veggie Pizza

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000001',   -- John Doe
    @RestaurantID = 'RES0000000000003', -- Sushi World
    @DeliveryAddressID = 'ADR0000000000001'; -- John's delivery address

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000006', 'RES0000000000003', 'FOO0000000000002', 1, 9.49, 'Extra spicy'
    ), -- 1 Spicy Tuna Roll
    (
        'ORD0000000000006', 'RES0000000000003', 'FOO0000000000004', 2, 10.99, NULL
    ), -- 2 Salmon Nigiri
    (
        'ORD0000000000006', 'RES0000000000003', 'FOO0000000000005', 1, 11.49, NULL
    ); -- 1 Tempura Udon

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000002',   -- Jane Smith
    @RestaurantID = 'RES0000000000004', -- Taco Town
    @DeliveryAddressID = 'ADR0000000000002'; -- Jane's delivery address

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000007', 'RES0000000000004', 'FOO0000000000001', 4, 6.00, 'Extra salsa'
    ), -- 4 Beef Tacos
    (
        'ORD0000000000007', 'RES0000000000004', 'FOO0000000000002', 2, 6.00, NULL
    ) -- 

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000003',   -- Alice Johnson
    @RestaurantID = 'RES0000000000001', -- Gourmet Bites
    @DeliveryAddressID = 'ADR0000000000001'; -- Alice's delivery address

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000008', 'RES0000000000001', 'FOO0000000000002', 1, 7.49, NULL
    ), -- 1 Veggie Wrap
    (
        'ORD0000000000008', 'RES0000000000001', 'FOO0000000000005', 1, 6.49, NULL
    ); -- 1 Avocado Toast

--------------------------------------------------------------
EXEC sp_InsertOrder
    @CustomerID = 'USR0000000000004',   -- Bob Brown
    @RestaurantID = 'RES0000000000002', -- Pizza Palace
    @DeliveryAddressID = 'ADR0000000000001'; -- Bob's delivery address

INSERT INTO [order_items]
    (
        order_id,
        restaurant_id,
        item_id,
        quantity,
        price,
        note
    )
VALUES
    (
        'ORD0000000000009', 'RES0000000000002', 'FOO0000000000005', 2, 14.49, NULL
    ), -- 2 Pepperoni Pizzas
    (
        'ORD0000000000009', 'RES0000000000002', 'FOO0000000000004', 1, 13.99, 'No olives'
    ); -- 1 Veggie Pizza


UPDATE [order]
SET status = 'ASSIGNING_DRIVER'
WHERE order_id IN ('ORD0000000000003');

UPDATE [order]
SET status = 'DELIVERING'
WHERE order_id IN ('ORD0000000000004');

UPDATE [order]
SET status = 'DELIVERED'
WHERE order_id IN ('ORD0000000000001', 'ORD0000000000002', 'ORD0000000000005');

UPDATE [order]
SET delivered_at = '2024-06-20 13:00:00'
WHERE order_id = 'ORD0000000000001';

UPDATE [order]
SET delivered_at = '2024-06-21 19:45:00'
WHERE order_id = 'ORD0000000000002';

UPDATE [order]
SET delivered_at = '2024-06-24 20:00:00'
WHERE order_id = 'ORD0000000000005';

-- ===========================================================
-- SAMPLE ORDER PAYMENTS
-- ===========================================================

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000001', -- Order by John Doe
    @PaymentMethodID = 'PAY0000000000006', -- John's E_WALLET
    @Status = 'FAILED',
    @CreatedAt = '2024-06-25 12:00:00';

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000001', -- Order by John Doe
    @PaymentMethodID = 'PAY0000000000001', -- John's BANK_CARD
    @Status = 'PAID',
    @PaidAt = '2024-06-20 13:06:00',
    @CreatedAt = '2024-06-20 13:05:00';

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000002', -- Order by Jane Smith
    @PaymentMethodID = 'PAY0000000000002', -- Jane's E_WALLET
    @Status = 'PAID',
    @PaidAt = '2024-06-21 19:16:00',
    @CreatedAt = '2024-06-21 19:15:00';

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000003', -- Order by Alice Johnson
    @PaymentMethodID = 'PAY0000000000003', -- Alice's CASH
    @Status = 'PENDING',
    @CreatedAt = '2024-06-22 13:16:00';

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000004', -- Order by Bob Brown
    @PaymentMethodID = 'PAY0000000000004', -- Bob's BANK_CARD
    @Status = 'PAID',
    @PaidAt = '2024-06-23 11:30:00',
    @CreatedAt = '2024-06-23 11:29:00';

EXEC sp_InsertOrderPayment
    @OrderID = 'ORD0000000000005', -- Order by Charlie Davis
    @PaymentMethodID = 'PAY0000000000005', -- Charlie's E_WALLET
    @Status = 'REFUNDED',
    @PaidAt = '2024-06-24 20:05:00',
    @CreatedAt = '2024-06-24 20:04:00';

-- ==========================================================
-- SAMPLE DRIVER REVIEWS
-- ==========================================================

INSERT INTO [driver_review]
    (
        order_id,
        driver_id,
        customer_id,
        rating_point,
        comment,
        created_at
    )
VALUES
    (
        'ORD0000000000001', 'USR0000000000008', 'USR0000000000001', 5, 'Great service and timely delivery!', '2024-06-20 14:00:00'
    ), -- Review by John Doe for David Wilson
    (
        'ORD0000000000002', 'USR0000000000008', 'USR0000000000002', 4, 'Good delivery, but was a bit late.', '2024-06-21 20:00:00'
    ), -- Review by Jane Smith for Eva Martinez
    (
        'ORD0000000000005', 'USR0000000000010', 'USR0000000000005', 4, 'Fast delivery, food was still hot.', '2024-06-24 21:00:00'
    ); -- Review by Charlie Davis for Hannah Lee

-- ==========================================================
-- SAMPLE RESTAURANT REVIEWS
-- ==========================================================
INSERT INTO [restaurant_review]
    (
        order_id,
        restaurant_id,
        customer_id,
        rating_point,
        comment,
        created_at
    )
VALUES
    (
        'ORD0000000000001', 'RES0000000000001', 'USR0000000000001', 5, 'Delicious food and great variety!', '2024-06-20 14:10:00'
    ), -- Review by John Doe for Gourmet Bites
    (
        'ORD0000000000002', 'RES0000000000002', 'USR0000000000002', 4, 'Tasty pizza but could use more toppings.', '2024-06-21 20:10:00'
    ), -- Review by Jane Smith for Pizza Palace
    (
        'ORD0000000000005', 'RES0000000000002', 'USR0000000000005', 5, 'Best pizza I have had in a long time!', '2024-06-24 21:10:00'
    ); -- Review by Charlie Davis for Pizza Palace

-- ==========================================================
-- SAMPLE CATEGORY ITEMS
-- ==========================================================

INSERT INTO [category_items]
    (
        category_name,
        restaurant_id,
        menu_item_id
    )
VALUES
    (
        'Healthy Food',
        'RES0000000000001', -- Gourmet Bites
        'FOO0000000000001'  -- Grilled Chicken Salad
    ),
    (
        'Healthy Food',
        'RES0000000000001', -- Gourmet Bites
        'FOO0000000000002'  -- Veggie Wrap
    ),
    (
        'Italian Cuisine',
        'RES0000000000002', -- Pizza Palace
        'FOO0000000000002'  -- Margherita Pizza
    ),
    (
        'Italian Cuisine',
        'RES0000000000002', -- Pizza Palace
        'FOO0000000000005'  -- Pepperoni Pizza
    ),
    (
        'Asian Cuisine',
        'RES0000000000003', -- Sushi World
        'FOO0000000000003'  -- California Roll
    ),
    (
        'Asian Cuisine',
        'RES0000000000003', -- Sushi World
        'FOO0000000000004'  -- Spicy Tuna Roll
    ),
    (
        'Fast Food',
        'RES0000000000004', -- Taco Town
        'FOO0000000000001'  -- Beef Taco
    ),
    (
        'Fast Food',
        'RES0000000000002', -- Pizza Palace
        'FOO0000000000004'  -- BBQ Chicken Pizza
    ),
    (
        'Healthy Food',
        'RES0000000000001', -- Gourmet Bites
        'FOO0000000000005'  -- Avocado Toast
    ),
    (
        'Asian Cuisine',
        'RES0000000000003', -- Sushi World
        'FOO0000000000005'  -- Tempura Udon
    ),
    (
        'Fast Food',
        'RES0000000000002', -- Pizza Palace
        'FOO0000000000003'  -- Veggie Pizza
    ),
    (
        'Italian Cuisine',
        'RES0000000000006', -- Pasta Place
        'FOO0000000000001'  -- Spaghetti Bolognese
    ),
    (
        'Italian Cuisine',
        'RES0000000000006', -- Pasta Place
        'FOO0000000000002'  -- Fettuccine Alfredo
    );

-- ==========================================================
-- SAMPLE PROMOTION
-- ==========================================================

EXEC sp_InsertPromotion
    @Type = 'PERCENTAGE_DISCOUNT',
    @MinOrderValue = 30.00,
    @DiscountValue = 2.00,
    @PercentDiscount = 5;

EXEC sp_InsertPromotion
    @Type = 'FIXED_AMOUNT_DISCOUNT',
    @MinOrderValue = 50.00,
    @DiscountValue = 10.00,
    @StartDate = '2024-07-01',
    @EndDate = '2024-07-31';

EXEC sp_InsertPromotion
    @Type = 'PERCENTAGE_DISCOUNT',
    @MinOrderValue = 20.00,
    @DiscountValue = 1.00,
    @PercentDiscount = 10,
    @StartDate = '2024-08-01',
    @EndDate = '2024-08-15',
    @OrderID = 'ORD0000000000001';

EXEC sp_InsertPromotion
    @Type = 'FIXED_AMOUNT_DISCOUNT',
    @MinOrderValue = 15.00,
    @DiscountValue = 3.00,
    @OrderID = 'ORD0000000000002';

EXEC sp_InsertPromotion
    @Type = 'PERCENTAGE_DISCOUNT',
    @MinOrderValue = 25.00,
    @DiscountValue = 2.50,
    @PercentDiscount = 8;

EXEC sp_InsertPromotion
    @Type = 'FIXED_AMOUNT_DISCOUNT',
    @MinOrderValue = 40.00,
    @DiscountValue = 5.00,
    @StartDate = '2024-09-01',
    @EndDate = '2024-09-30';

EXEC sp_InsertPromotion
    @Type = 'PERCENTAGE_DISCOUNT',
    @MinOrderValue = 10.00,
    @DiscountValue = 1.00,
    @PercentDiscount = 15,
    @StartDate = '2024-10-01',
    @EndDate = '2024-10-15',
    @OrderID = 'ORD0000000000003';

-- ==================================================
-- SAMPLE SUPPORT REQUESTS
-- ==================================================

EXEC sp_InsertSupportRequest
    @UserID = 'USR0000000000001', -- John Doe
    @IssueType = 'ORDER_ISSUE',
    @OrderID = 'ORD0000000000001',
    @Description = 'The delivery was late and the food was cold.',
    @CreatedAt = '2024-06-21 10:00:00';

EXEC sp_InsertSupportRequest
    @UserID = 'USR0000000000002', -- Jane Smith
    @IssueType = 'PAYMENT_ISSUE',
    @Description = 'My payment method was declined even though I have sufficient funds.',
    @CreatedAt = '2024-06-22 11:30:00';

EXEC sp_InsertSupportRequest
    @UserID = 'USR0000000000003', -- Alice Johnson
    @IssueType = 'APP_FEEDBACK',
    @Description = 'The app crashes every time I try to place an order.',
    @CreatedAt = '2024-06-23 09:15:00';

EXEC sp_InsertSupportRequest
    @UserID = 'USR0000000000004', -- Bob Brown
    @IssueType = 'DELIVERY_ISSUE',
    @Description = 'The driver could not find my address.',
    @CreatedAt = '2024-06-24 14:45:00';

-- =================================================
-- SAMPLE NOTIFICATIONS
-- ==================================================

EXEC sp_InsertNotification
    @UserID = 'USR0000000000001', -- John Doe
    @Type = 'ORDER_UPDATE',
    @OrderID = 'ORD0000000000001',
    @Message = 'Your order ORD0000000000001 has been delivered successfully.',
    @SentAt = '2024-06-20 14:05:00';

EXEC sp_InsertNotification
    @UserID = 'USR0000000000002', -- Jane Smith
    @Type = 'ORDER_UPDATE',
    @OrderID = 'ORD0000000000002',
    @Message = 'Your payment for order ORD0000000000002 was successful.',
    @SentAt = '2024-06-21 19:20:00';

EXEC sp_InsertNotification
    @UserID = 'USR0000000000003', -- Alice Johnson
    @Type = 'ORDER_UPDATE',
    @OrderID = 'ORD0000000000003',
    @Message = 'A driver has been assigned to your order ORD0000000000003.',
    @SentAt = '2024-06-22 13:20:00';

EXEC sp_InsertNotification
    @UserID = 'USR0000000000004', -- Bob Brown
    @Type = 'ORDER_UPDATE',
    @OrderID = 'ORD0000000000004',
    @Message = 'Your order ORD0000000000004 is out for delivery.',
    @SentAt = '2024-06-23 11:10:00';
      



