import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class PaymentMethodResponseDto {
  @ApiProperty()
  payment_id: string;

  @ApiProperty()
  customer_id: string;

  @ApiProperty({ enum: ['CASH', 'E_WALLET', 'BANK_CARD'] })
  type: 'CASH' | 'E_WALLET' | 'BANK_CARD';

  @ApiProperty()
  created_at: Date;
}

export class CreatePaymentMethodDto {
  @ApiProperty({ enum: ['CASH', 'E_WALLET', 'BANK_CARD'] })
  type: 'CASH' | 'E_WALLET' | 'BANK_CARD';

  @ApiPropertyOptional()
  provider?: string;

  @ApiPropertyOptional()
  wallet_number?: string;

  @ApiPropertyOptional()
  bank_name?: string;

  @ApiPropertyOptional()
  card_number?: string;

  @ApiPropertyOptional()
  expiry_date?: string;
}
