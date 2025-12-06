import { IsString, IsOptional } from 'class-validator';
import { Expose } from 'class-transformer';

export class UpdateUserRequestDto {
  @IsOptional()
  @IsString()
  name?: string;
}

export class GetUserResponseDto {
  @Expose()
  userId: string;

  @Expose()
  email: string;

  @Expose()
  name: string;
}
