import { IsNotEmpty, IsString, IsNumber, IsDecimal, MaxLength, Min, Max, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateAddressDto {
  @ApiProperty({ description: 'Recipient name', maxLength: 128 })
  @IsNotEmpty()
  @IsString()
  @MaxLength(128)
  recipientName: string;

  @ApiProperty({ description: 'Phone number', maxLength: 16 })
  @IsNotEmpty()
  @IsString()
  @MaxLength(16)
  phone: string;

  @ApiProperty({ description: 'Longitude coordinate', type: 'number' })
  @IsNotEmpty()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  longitude: number;

  @ApiProperty({ description: 'Latitude coordinate', type: 'number' })
  @IsNotEmpty()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  latitude: number;

  @ApiProperty({ description: 'Address details', maxLength: 256 })
  @IsNotEmpty()
  @IsString()
  @MaxLength(256)
  details: string;
}

export class UpdateAddressDto {
  @ApiPropertyOptional({ description: 'Recipient name', maxLength: 128 })
  @IsOptional()
  @IsString()
  @MaxLength(128)
  recipientName?: string;

  @ApiPropertyOptional({ description: 'Phone number', maxLength: 16 })
  @IsOptional()
  @IsString()
  @MaxLength(16)
  phone?: string;

  @ApiPropertyOptional({ description: 'Longitude coordinate', type: 'number' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  longitude?: number;

  @ApiPropertyOptional({ description: 'Latitude coordinate', type: 'number' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  latitude?: number;

  @ApiPropertyOptional({ description: 'Address details', maxLength: 256 })
  @IsOptional()
  @IsString()
  @MaxLength(256)
  details?: string;
}
