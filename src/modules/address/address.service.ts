import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from 'src/database/prisma.service';
import { CreateAddressDto } from './dtos';

@Injectable()
export class AddressService {
  constructor(private readonly prisma: PrismaService) {}

  async createAddress(request: CreateAddressDto, customerId: string) {
    try {
      const result = await this.prisma.$queryRaw<any[]>`
        EXEC sp_InsertDeliveryAddress 
          @CustomerID = ${customerId},
          @RecipientName = ${request.recipientName},
          @Phone = ${request.phone},
          @Longitude = ${request.longitude},
          @Latitude = ${request.latitude},
          @Details = ${request.details}
      `;
      return result[0].NewAddressID;
    } catch (error) {
      throw new BadRequestException('Cannot create delivery address');
    }
  }
}
