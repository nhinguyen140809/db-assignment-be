import { IsString, IsOptional } from 'class-validator';
import { Expose } from 'class-transformer';

export class UpdateUserRequestDto {
  @IsOptional()
  @IsString()
  firstName?: string;

  @IsOptional()
  @IsString()
  lastName?: string;
}

export class GetUserResponseDto {
  @Expose()
  userId: string;

  @Expose()
  email: string;

  @Expose()
  firstName: string;

  @Expose()
  lastName: string;

  @Expose()
  role?: string;

  @Expose()
  phone?: string;
}
