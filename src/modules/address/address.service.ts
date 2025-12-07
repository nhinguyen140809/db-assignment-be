import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/database/prisma.service';
import { CreateAddressDto, UpdateAddressDto } from './dtos';
import { Prisma } from '@prisma/client';

@Injectable()
export class AddressService {
  constructor(private readonly prisma: PrismaService) {}

  async createAddress(data: CreateAddressDto, customerId: string) {
    try {
      const result = await this.prisma.$queryRaw<any[]>`
        EXEC sp_InsertDeliveryAddress 
          @CustomerID = ${customerId},
          @RecipientName = ${data.recipientName},
          @Phone = ${data.phone},
          @Longitude = ${data.longitude},
          @Latitude = ${data.latitude},
          @Details = ${data.details}
      `;
      return result[0]?.NewAddressID;
    } catch (error) {
      console.error('Error creating delivery address:', error);
      throw new BadRequestException(error instanceof Error ? error.message : 'Cannot create delivery address');
    }
  }

  async getAllAddresses(customerId: string) {
    try {
      const addresses = await this.prisma.delivery_address.findMany({
        where: {
          customer_id: customerId,
        },
        orderBy: {
          address_id: 'desc',
        },
      });

      return addresses;
    } catch (error) {
      console.error('Error fetching delivery addresses:', error);
      throw new BadRequestException(error instanceof Error ? error.message : 'Cannot fetch delivery addresses');
    }
  }

  async getAddressById(addressId: string, customerId: string) {
    try {
      const address = await this.prisma.delivery_address.findUnique({
        where: {
          address_id_customer_id: {
            address_id: addressId,
            customer_id: customerId,
          },
        },
      });

      if (!address) {
        throw new NotFoundException('Delivery address not found or does not belong to you');
      }

      return address;
    } catch (error) {
      console.error('Error fetching delivery address:', error);
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(error instanceof Error ? error.message : 'Cannot fetch delivery address');
    }
  }

  async updateAddress(addressId: string, customerId: string, data: UpdateAddressDto) {
    try {
      // First check if the address exists and belongs to the customer
      const existingAddress = await this.prisma.delivery_address.findUnique({
        where: {
          address_id_customer_id: {
            address_id: addressId,
            customer_id: customerId,
          },
        },
      });

      if (!existingAddress) {
        throw new NotFoundException('Delivery address not found or does not belong to you');
      }

      // Update the address
      const updatedAddress = await this.prisma.delivery_address.update({
        where: {
          address_id_customer_id: {
            address_id: addressId,
            customer_id: customerId,
          },
        },
        data: {
          recipient_name: data.recipientName,
          phone: data.phone,
          longitude: data.longitude,
          latitude: data.latitude,
          details: data.details,
        },
      });

      return updatedAddress;
    } catch (error) {
      console.error('Error updating delivery address:', error);
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(error instanceof Error ? error.message : 'Cannot update delivery address');
    }
  }

  async deleteAddress(addressId: string, customerId: string) {
    try {
      // First check if the address exists and belongs to the customer
      const existingAddress = await this.prisma.delivery_address.findUnique({
        where: {
          address_id_customer_id: {
            address_id: addressId,
            customer_id: customerId,
          },
        },
      });

      if (!existingAddress) {
        throw new NotFoundException('Delivery address not found or does not belong to you');
      }

      // Delete the address
      await this.prisma.delivery_address.delete({
        where: {
          address_id_customer_id: {
            address_id: addressId,
            customer_id: customerId,
          },
        },
      });

      return { message: 'Delivery address deleted successfully' };
    } catch (error) {
      console.error('Error deleting delivery address:', error);
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(error instanceof Error ? error.message : 'Cannot delete delivery address');
    }
  }
}
