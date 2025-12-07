import { IsString, IsOptional, IsNumber, IsEnum, Min, Max, IsNotEmpty, IsDecimal, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMenuItemDto {
  @ApiProperty({ description: 'Menu item name' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  name: string;

  @ApiPropertyOptional({ description: 'Menu item description' })
  @IsString()
  @IsOptional()
  @MaxLength(512)
  description?: string;

  @ApiProperty({ description: 'Price of the menu item' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  price: number;

  @ApiProperty({ description: 'Restaurant ID' })
  @IsString()
  @IsNotEmpty()
  restaurant_id: string;

  @ApiPropertyOptional({ description: 'Status of the menu item', enum: ['AVAILABLE', 'UNAVAILABLE'] })
  @IsString()
  @IsOptional()
  @IsEnum(['AVAILABLE', 'UNAVAILABLE'])
  status?: string;
}

export class UpdateMenuItemDto {
  @ApiPropertyOptional({ description: 'Menu item name' })
  @IsString()
  @IsOptional()
  @MaxLength(128)
  name?: string;

  @ApiPropertyOptional({ description: 'Menu item description' })
  @IsString()
  @IsOptional()
  @MaxLength(512)
  description?: string;

  @ApiPropertyOptional({ description: 'Price of the menu item' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsOptional()
  @Min(0)
  price?: number;

  @ApiPropertyOptional({ description: 'Status of the menu item', enum: ['AVAILABLE', 'UNAVAILABLE'] })
  @IsString()
  @IsOptional()
  @IsEnum(['AVAILABLE', 'UNAVAILABLE'])
  status?: string;

  @ApiPropertyOptional({ description: 'Categories for the menu item', type: [String] })
  @IsOptional()
  @IsString({ each: true })
  categories?: string[];
}

export class MenuItemSearchDto {
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

  @ApiPropertyOptional({ description: 'Sort by field', default: 'name' })
  @IsOptional()
  @IsString()
  sortBy?: string = 'name';

  @ApiPropertyOptional({ description: 'Sort order', enum: ['asc', 'desc'], default: 'asc' })
  @IsOptional()
  @IsEnum(['asc', 'desc'])
  sortOrder?: 'asc' | 'desc' = 'asc';

  @ApiPropertyOptional({ description: 'Search query' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Filter by category' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ description: 'Filter by restaurant ID' })
  @IsOptional()
  @IsString()
  restaurantId?: string;

  @ApiPropertyOptional({ description: 'Minimum price' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  minPrice?: number;

  @ApiPropertyOptional({ description: 'Maximum price' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  maxPrice?: number;

  @ApiPropertyOptional({ description: 'Filter by status', enum: ['AVAILABLE', 'UNAVAILABLE'] })
  @IsOptional()
  @IsString()
  @IsEnum(['AVAILABLE', 'UNAVAILABLE'])
  status?: string;
}

export class ToggleFavoriteDto {
  @ApiProperty({ description: 'Restaurant ID' })
  @IsString()
  @IsNotEmpty()
  restaurant_id: string;
}
