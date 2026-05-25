import { Controller, Get, Body, Patch, Param, Delete, UnauthorizedException, Post, Put } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { GetUserResponseDto, UpdateUserRequestDto, PaymentMethodResponseDto, CreatePaymentMethodDto } from './dtos';
import { plainToInstance } from 'class-transformer';
import { CurrentUser } from '../../common';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved', type: GetUserResponseDto })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUser(@CurrentUser() userId: string): Promise<GetUserResponseDto> {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    const currentUser = await this.usersService.getUser(userId);
    return plainToInstance(GetUserResponseDto, currentUser, {
      excludeExtraneousValues: true,
    });
  }

  @Patch()
  async updateUser(@CurrentUser() userId: string, @Body() updateUserRequestDto: UpdateUserRequestDto): Promise<void> {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    return await this.usersService.updateUser(userId, updateUserRequestDto);
  }

  @Delete()
  async deleteUser(@CurrentUser() userId: string): Promise<void> {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    return await this.usersService.deleteUser(userId);
  }

  // Payment methods

  @Get('payment-methods')
  @ApiOperation({ summary: 'Get payment methods for current user' })
  @ApiResponse({ status: 200, description: 'List of payment methods', type: [PaymentMethodResponseDto] })
  async getMyPaymentMethods(@CurrentUser() userId: string) {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    return this.usersService.getPaymentMethodsForUser(userId);
  }

  @Post('payment-methods')
  @ApiOperation({ summary: 'Create payment method for current user' })
  @ApiResponse({ status: 201, description: 'Payment method created', type: PaymentMethodResponseDto })
  async createMyPaymentMethod(@CurrentUser() userId: string, @Body() body: any) {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    return this.usersService.createPaymentMethodForUser(userId, body);
  }

  @Get('payment-methods/:paymentId')
  @ApiOperation({ summary: 'Get a payment method by ID' })
  @ApiResponse({ status: 200, description: 'Payment method retrieved', type: PaymentMethodResponseDto })
  async getMyPaymentMethodById(@Param('paymentId') paymentId: string, @CurrentUser() userId: string) {
    if (!userId) throw new UnauthorizedException('Unauthorized: missing user');
    return this.usersService.getPaymentMethodById(userId, paymentId);
  }

  @Put('payment-methods/:paymentId')
  @ApiOperation({ summary: 'Update a payment method' })
  @ApiResponse({ status: 200, description: 'Payment method updated', type: PaymentMethodResponseDto })
  async updateMyPaymentMethod(@Param('paymentId') paymentId: string, @CurrentUser() userId: string, @Body() body: any) {
    if (!userId) throw new UnauthorizedException('Unauthorized: missing user');
    return this.usersService.updatePaymentMethodForUser(userId, paymentId, body);
  }

  @Post('change-password')
  @ApiOperation({ summary: 'Change current user password' })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  async changePassword(@CurrentUser() userId: string, @Body() body: { current_password: string; new_password: string }) {
    if (!userId) throw new UnauthorizedException('Unauthorized: missing user');
    await this.usersService.changePassword(userId, body.current_password, body.new_password);
    return { message: 'Password changed successfully' };
  }

  @Delete('payment-methods/:paymentId')
  @ApiOperation({ summary: 'Delete a payment method for current user' })
  @ApiResponse({ status: 200, description: 'Payment method deleted' })
  async deleteMyPaymentMethod(@Param('paymentId') paymentId: string, @CurrentUser() userId: string) {
    if (!userId) {
      throw new UnauthorizedException('Unauthorized: missing user');
    }
    return this.usersService.deletePaymentMethodForUser(userId, paymentId);
  }
}
