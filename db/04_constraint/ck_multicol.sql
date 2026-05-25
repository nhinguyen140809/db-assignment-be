-- =========================================
-- File: ck_multicol.sql
-- Purpose: Define CHECK constraints involving multiple columns.
-- =========================================

ALTER TABLE [customer]
ADD CONSTRAINT CK_Customer_Recommend CHECK ([recommended_customer_id] IS NULL
                                            OR [recommended_customer_id] <> [customer_id]
                                           );

ALTER TABLE [operating_hour]
ADD CONSTRAINT CK_OperatingHour_TimeRange CHECK ([close_time] > [open_time]);

ALTER TABLE [order]
ADD CONSTRAINT CK_Order_Time CHECK ([delivered_at] IS NULL
                                    OR [ordered_at] IS NULL
                                    OR [delivered_at] >= [ordered_at]
                                   );

ALTER TABLE [order_payments]
ADD CONSTRAINT CK_OrderPayment_Time CHECK ([paid_at] IS NULL
                                           OR [paid_at] >= [created_at]
                                          );

ALTER TABLE [promotion]
ADD CONSTRAINT CK_Promotion_Date CHECK ([start_date] IS NULL 
                                        OR [end_date] IS NULL 
                                        OR [end_date] >= [start_date]
                                       );