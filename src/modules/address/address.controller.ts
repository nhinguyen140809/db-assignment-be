import { Body, Controller, Post, Patch, Param, Get, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AddressService } from './address.service';
import { JwtAuthGuard } from '../auth/guards';
import { CreateAddressDto, UpdateAddressDto } from './dtos';
import { CurrentUser } from 'src/common';

@ApiTags('Addresses')
@ApiBearerAuth()
@Controller('addresses')
export class AddressController {
  constructor(private readonly addressService: AddressService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Create a new delivery address' })
  @ApiResponse({ status: 201, description: 'Delivery address created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createDeliveryAddress(@Body() createAddressDto: CreateAddressDto, @CurrentUser() user: Express.User) {
    return this.addressService.createAddress(createAddressDto, user.userId);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get all delivery addresses of current user' })
  @ApiResponse({ status: 200, description: 'List of delivery addresses retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAllDeliveryAddresses(@CurrentUser() user: Express.User) {
    return this.addressService.getAllAddresses(user.userId);
  }

  @Get(':addressId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get a specific delivery address by ID' })
  @ApiResponse({ status: 200, description: 'Delivery address retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Delivery address not found' })
  async getDeliveryAddressById(@Param('addressId') addressId: string, @CurrentUser() user: Express.User) {
    return this.addressService.getAddressById(addressId, user.userId);
  }

  @Patch(':addressId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Update a delivery address' })
  @ApiResponse({ status: 200, description: 'Delivery address updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Delivery address not found' })
  async updateDeliveryAddress(
    @Param('addressId') addressId: string,
    @Body() updateAddressDto: UpdateAddressDto,
    @CurrentUser() user: Express.User,
  ) {
    return this.addressService.updateAddress(addressId, user.userId, updateAddressDto);
  }

  @Delete(':addressId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Delete a delivery address' })
  @ApiResponse({ status: 200, description: 'Delivery address deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Delivery address not found' })
  async deleteDeliveryAddress(@Param('addressId') addressId: string, @CurrentUser() user: Express.User) {
    return this.addressService.deleteAddress(addressId, user.userId);
  }
}
