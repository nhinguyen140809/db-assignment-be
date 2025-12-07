import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum, IsOptional } from 'class-validator';
import { Expose } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LoginRequestDto {
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;
}

export class RegisterRequestDto {
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ description: 'First name' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ description: 'Last name' })
  @IsNotEmpty()
  @IsString()
  lastName: string;

  @ApiProperty({ description: 'User role', enum: ['customer', 'driver', 'restaurant_owner'] })
  @IsNotEmpty()
  @IsEnum(['customer', 'driver', 'restaurant_owner'])
  role: 'customer' | 'driver' | 'restaurant_owner';

  @ApiPropertyOptional({ description: 'Phone number' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ description: 'Recommended customer ID (for customer role only)' })
  @IsOptional()
  @IsString()
  recommendedCustomerId?: string;
}

export class AuthResponseDto {
  @Expose()
  accessToken: string;

  @Expose()
  authUser: {
    userId: string;
    email: string;
    name: string;
    role?: string;
    phone?: string;
  };
}
