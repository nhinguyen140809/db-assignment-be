import { ApiProperty } from '@nestjs/swagger';

export class PaymentMethodResponseDto {
  @ApiProperty()
  payment_id: string;

  @ApiProperty()
  customer_id: string;

  @ApiProperty({ enum: ['CASH'] })
  type: 'CASH';

  @ApiProperty()
  created_at: Date;
}

export class CreatePaymentMethodDto {
  @ApiProperty({ enum: ['CASH'] })
  type: 'CASH';
}
