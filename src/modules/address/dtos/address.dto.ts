import { IsNotEmpty, IsString, IsNumber, IsDecimal, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
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
  @Type(() => Number)
  longitude: number;

  @ApiProperty({ description: 'Latitude coordinate', type: 'number' })
  @IsNotEmpty()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Type(() => Number)
  latitude: number;

  @ApiProperty({ description: 'Address details', maxLength: 256 })
  @IsNotEmpty()
  @IsString()
  @MaxLength(256)
  details: string;
}
