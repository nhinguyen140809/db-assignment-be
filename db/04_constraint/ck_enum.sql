-- ======================================
-- File: ck_enum.sql
-- Purpose: Define CHECK constraints for ENUM-like columns.
-- ======================================

-- ALTER TABLE [user]
-- ADD CONSTRAINT CK_User_Role CHECK ([role] IN ( 'CUSTOMER', 'DRIVER', 'OWNER' ));

ALTER TABLE [driver]
ADD CONSTRAINT CK_Driver_Status CHECK ([status] IN ( 'OFFLINE', 'ONLINE', 'BUSY' ));

ALTER TABLE [vehicle]
ADD CONSTRAINT CK_Vehicle_Model CHECK ([model] IN ( 'Honda SH', 'Honda Vision', 'Yamaha NVX', 'Yamaha Exciter',
                                                    'Piaggio Liberty', 'Honda Air Blade', 'Honda Vario',
                                                    'Yamaha Grande', 'Yamaha Janus', 'Honda Wave', 'Honda Cub',
                                                    'Honda Future', 'Suzuki Impulse', 'SYM Attila', 'SYM Elizabeth'
                                                  )
                                    );

-- ALTER TABLE [payment_method]
-- ADD CONSTRAINT CK_PaymentMethod_Type CHECK ([type] IN ( 'BANK_CARD', 'E_WALLET', 'CASH' ));

ALTER TABLE [restaurant]
ADD CONSTRAINT CK_Restaurant_Status CHECK ([status] IN ( 'OPEN', 'CLOSED', 'UNAVAILABLE' ));

ALTER TABLE [menu_item]
ADD CONSTRAINT CK_MenuItem_Status CHECK ([status] IN ( 'AVAILABLE', 'UNAVAILABLE', 'DELETED' ));

ALTER TABLE [order]
ADD CONSTRAINT CK_Order_Status CHECK ([status] IN ( 'IN_CART', 'PLACED', 'CONFIRMED', 'ASSIGNING_DRIVER',
                                                    'DRIVER_ASSIGNED', 'PREPARING', 'PICKUP_READY', 'DELIVERING',
                                                    'DELIVERED', 'COMPLETED', 'CANCELLED'
                                                  )
                                     );

ALTER TABLE [order_payments]
ADD CONSTRAINT CK_OrderPayment_Status CHECK ([status] IN ( 'UNPAID', 'PENDING', 'PAID', 'FAILED', 'REFUNDING',
                                                           'REFUNDED'
                                                         )
                                            );

-- ALTER TABLE [promotion]
-- ADD CONSTRAINT CK_Promotion_Type CHECK ([type] IN ( 'DELIVERY_FEE_DISCOUNT', 'PERCENTAGE_DISCOUNT',
--                                                     'FIXED_AMOUNT_DISCOUNT'
--                                                   )
--                                        );

ALTER TABLE [notification]
ADD CONSTRAINT CK_Notification_Type CHECK ([type] IN ( 'ORDER_UPDATE', 'INVOICE' )); -- còn loại nào nữa không?

ALTER TABLE [support_request]
ADD CONSTRAINT CK_SupportRequest_Status CHECK ([status] IN ( 'PENDING', 'IN_PROGRESS', 'RESOLVED' ));

ALTER TABLE [support_request]
ADD CONSTRAINT CK_SupportRequest_IssueType CHECK ([issue_type] IN ( 'ORDER_ISSUE', 'PAYMENT_ISSUE', 'DELIVERY_ISSUE',
                                                                    'APP_FEEDBACK', 'OTHER'
                                                                  )
                                                 );

