-- ==============================================================
-- File: ck_range.sql
-- Purpose: Define CHECK constraints for columns with specific value ranges.
-- ==============================================================


ALTER TABLE [restaurant_review]
ADD CONSTRAINT CK_RestaurantReview_Rating CHECK ([rating_point]
                                                 BETWEEN 1 AND 5
                                                );
ALTER TABLE [driver_review]
ADD CONSTRAINT CK_DriverReview_Rating CHECK ([rating_point]
                                             BETWEEN 1 AND 5
                                            );

ALTER TABLE [percentage_discount]
ADD CONSTRAINT CK_PercentageDiscount_Percent CHECK ([discount_percent]
                                                    BETWEEN 1 AND 100
                                                   );

ALTER TABLE [fixed_amount_discount]
ADD CONSTRAINT CK_FixedAmountDiscount_Amount CHECK ([fixed_discount_amount] > 0);

ALTER TABLE [delivery_fee_discount]
ADD CONSTRAINT CK_DeliveryFeeDiscount_Amount CHECK ([ship_discount_amount] > 0);

ALTER TABLE [percentage_discount]
ADD CONSTRAINT CK_PercentageDiscount_MaxAmount CHECK ([max_discount_amount] IS NULL
                                                      OR [max_discount_amount] > 0
                                                     );

ALTER TABLE [order]
ADD CONSTRAINT CK_Order_DeliveryFee CHECK ([delivery_fee] IS NULL
                                           OR [delivery_fee] >= 0
                                          );

ALTER TABLE [menu_item]
ADD CONSTRAINT CK_MenuItem_Price CHECK ([price] >= 0);

ALTER TABLE [promotion]
ADD CONSTRAINT CK_Promotion_MinOrderValue CHECK ([min_order_value] >= 0);

ALTER TABLE [order_items]
ADD CONSTRAINT CK_OrderItems_Price CHECK ([price] IS NULL
                                          OR [price] >= 0
                                         );

ALTER TABLE [order_items]
ADD CONSTRAINT CK_OrderItems_Quantity CHECK ([quantity] > 0);

ALTER TABLE [operating_hour]
ADD CONSTRAINT CK_OperatingHour_DayOfWeek CHECK ([dow]
                                                 BETWEEN 0 AND 6
                                                );
