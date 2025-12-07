import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AddressService } from './address.service';
import { JwtAuthGuard } from '../auth/guards';
import { CreateAddressDto } from './dtos';
import { CurrentUser } from 'src/common';

@Controller('addresses')
export class AddressController {
  constructor(private readonly addressService: AddressService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createDeliveryAddress(@Body() createAddressDto: CreateAddressDto, @CurrentUser() user: Express.User) {
    return this.addressService.createAddress(createAddressDto, user.userId);
  }
}
