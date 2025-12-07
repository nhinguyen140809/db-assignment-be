import {
  IsString,
  IsOptional,
  IsNumber,
  IsEnum,
  IsEmail,
  Min,
  Max,
  IsNotEmpty,
  MaxLength,
  IsArray,
  ValidateNested,
  IsInt,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateRestaurantDto {
  @ApiProperty({ description: 'Restaurant name' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  name: string;

  @ApiPropertyOptional({ description: 'Restaurant phone number' })
  @IsString()
  @IsOptional()
  @MaxLength(16)
  phone?: string;

  @ApiPropertyOptional({ description: 'Restaurant email' })
  @IsEmail()
  @IsOptional()
  @MaxLength(64)
  email?: string;

  @ApiPropertyOptional({ description: 'Restaurant address details' })
  @IsString()
  @IsOptional()
  @MaxLength(256)
  address_details?: string;

  @ApiPropertyOptional({ description: 'Longitude coordinate' })
  @IsNumber()
  @IsOptional()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @ApiPropertyOptional({ description: 'Latitude coordinate' })
  @IsNumber()
  @IsOptional()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @ApiPropertyOptional({ description: 'Restaurant status', enum: ['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'] })
  @IsString()
  @IsOptional()
  @IsEnum(['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'])
  status?: string;

  @ApiPropertyOptional({ description: 'Operating hours', type: [Object] })
  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => OperatingHourDto)
  operating_hours?: OperatingHourDto[];
}

export class OperatingHourDto {
  @ApiProperty({ description: 'Day of week (0=Sunday, 1=Monday, ...)', minimum: 0, maximum: 6 })
  @IsInt()
  @Min(0)
  @Max(6)
  dow: number;

  @ApiProperty({ description: 'Opening time (HH:mm:ss)' })
  @IsString()
  @IsNotEmpty()
  open_time: string;

  @ApiPropertyOptional({ description: 'Closing time (HH:mm:ss)' })
  @IsString()
  @IsOptional()
  close_time?: string;
}

export class UpdateRestaurantDto {
  @ApiPropertyOptional({ description: 'Restaurant name' })
  @IsString()
  @IsOptional()
  @MaxLength(128)
  name?: string;

  @ApiPropertyOptional({ description: 'Restaurant phone number' })
  @IsString()
  @IsOptional()
  @MaxLength(16)
  phone?: string;

  @ApiPropertyOptional({ description: 'Restaurant email' })
  @IsEmail()
  @IsOptional()
  @MaxLength(64)
  email?: string;

  @ApiPropertyOptional({ description: 'Restaurant address details' })
  @IsString()
  @IsOptional()
  @MaxLength(256)
  address_details?: string;

  @ApiPropertyOptional({ description: 'Longitude coordinate' })
  @IsNumber()
  @IsOptional()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @ApiPropertyOptional({ description: 'Latitude coordinate' })
  @IsNumber()
  @IsOptional()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @ApiPropertyOptional({ description: 'Restaurant status', enum: ['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'] })
  @IsString()
  @IsOptional()
  @IsEnum(['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'])
  status?: string;

  @ApiPropertyOptional({ description: 'Operating hours', type: [Object] })
  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => OperatingHourDto)
  operating_hours?: OperatingHourDto[];
}

export class RestaurantSearchDto {
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

  @ApiPropertyOptional({ description: 'Filter by status', enum: ['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'] })
  @IsOptional()
  @IsString()
  @IsEnum(['OPEN', 'CLOSED', 'TEMPORARILY_CLOSED'])
  status?: string;

  @ApiPropertyOptional({ description: 'Minimum rating' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  minRating?: number;

  @ApiPropertyOptional({ description: 'User latitude for distance calculation' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @ApiPropertyOptional({ description: 'User longitude for distance calculation' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;

  @ApiPropertyOptional({ description: 'Search radius in km' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  radius?: number;
}
