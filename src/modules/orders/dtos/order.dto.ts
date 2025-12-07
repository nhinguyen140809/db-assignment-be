import { IsString, IsOptional, IsNumber, IsEnum, IsNotEmpty, Min, Max, IsInt } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateOrderDto {
  @ApiProperty({ description: 'Restaurant ID' })
  @IsString()
  @IsNotEmpty()
  restaurant_id: string;

  @ApiProperty({ description: 'Delivery address ID' })
  @IsString()
  @IsNotEmpty()
  delivery_id: string;

  @ApiPropertyOptional({ description: 'Customer note' })
  @IsString()
  @IsOptional()
  customer_note?: string;
}

export class UpdateOrderDto {
  @ApiPropertyOptional({ description: 'Order status' })
  @IsString()
  @IsOptional()
  @IsEnum(['IN_CART', 'PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERING', 'DELIVERED', 'CANCELLED'])
  status?: string;

  @ApiPropertyOptional({ description: 'Driver ID' })
  @IsString()
  @IsOptional()
  driver_id?: string;

  @ApiPropertyOptional({ description: 'Customer note' })
  @IsString()
  @IsOptional()
  customer_note?: string;

  @ApiPropertyOptional({ description: 'Delivery fee' })
  @IsNumber()
  @IsOptional()
  delivery_fee?: number;
}

export class AddOrderItemDto {
  @ApiProperty({ description: 'Restaurant ID' })
  @IsString()
  @IsNotEmpty()
  restaurant_id: string;

  @ApiProperty({ description: 'Menu item ID' })
  @IsString()
  @IsNotEmpty()
  item_id: string;

  @ApiProperty({ description: 'Quantity' })
  @IsInt()
  @Min(1)
  quantity: number;

  @ApiPropertyOptional({ description: 'Special instructions' })
  @IsString()
  @IsOptional()
  note?: string;
}

export class UpdateOrderItemDto {
  @ApiPropertyOptional({ description: 'Quantity' })
  @IsInt()
  @IsOptional()
  @Min(1)
  quantity?: number;

  @ApiPropertyOptional({ description: 'Special instructions' })
  @IsString()
  @IsOptional()
  note?: string;
}

export class OrderSearchDto {
  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 10;

  @ApiPropertyOptional({ description: 'Filter by status' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: 'Filter by restaurant ID' })
  @IsOptional()
  @IsString()
  restaurantId?: string;

  @ApiPropertyOptional({ description: 'Sort by field', default: 'ordered_at' })
  @IsOptional()
  @IsString()
  sortBy?: string = 'ordered_at';

  @ApiPropertyOptional({ description: 'Sort order', enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  @IsEnum(['asc', 'desc'])
  sortOrder?: 'asc' | 'desc' = 'desc';
}

export class CheckoutDto {
  @ApiProperty({ description: 'Delivery address ID' })
  @IsString()
  @IsNotEmpty()
  delivery_id: string;

  @ApiProperty({ description: 'Payment method ID' })
  @IsString()
  @IsNotEmpty()
  payment_method_id: string;
}

export class CancelOrderDto {
  @ApiPropertyOptional({ description: 'Cancellation reason' })
  @IsString()
  @IsOptional()
  reason?: string;
}

export class RateRestaurantDto {
  @ApiProperty({ description: 'Rating (1-5)', minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  rating_point: number;

  @ApiPropertyOptional({ description: 'Review comment' })
  @IsString()
  @IsOptional()
  comment?: string;
}

export class RateDriverDto {
  @ApiProperty({ description: 'Rating (1-5)', minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  rating_point: number;

  @ApiPropertyOptional({ description: 'Review comment' })
  @IsString()
  @IsOptional()
  comment?: string;
}
