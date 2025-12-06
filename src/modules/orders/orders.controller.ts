import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import {
  CreateOrderDto,
  UpdateOrderDto,
  AddOrderItemDto,
  UpdateOrderItemDto,
  OrderSearchDto,
  CheckoutDto,
  CancelOrderDto,
  RateRestaurantDto,
  RateDriverDto,
} from './dtos';
import { Order, OrderWithDetails, OrderItem, OrderStatistics } from './interfaces';
import { CurrentUser } from '../../common/decorators';

@ApiTags('Orders')
@ApiBearerAuth()
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all orders with filters' })
  @ApiResponse({ status: 200, description: 'Returns paginated orders' })
  async getOrders(@Query() params: OrderSearchDto, @CurrentUser() userId: string) {
    return this.ordersService.getOrders(params, userId);
  }

  @Get('my-orders')
  @ApiOperation({ summary: 'Get current user orders' })
  @ApiResponse({ status: 200, description: 'Returns user orders' })
  async getMyOrders(@Query('status') status: string, @CurrentUser() userId: string): Promise<OrderWithDetails[]> {
    return this.ordersService.getMyOrders(userId, status);
  }

  @Get('cart')
  @ApiOperation({ summary: 'Get current cart' })
  @ApiResponse({ status: 200, description: 'Returns current cart' })
  async getCart(@CurrentUser() userId: string): Promise<OrderWithDetails | null> {
    return this.ordersService.getCart(userId);
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get order statistics' })
  @ApiResponse({ status: 200, description: 'Returns order statistics' })
  async getOrderStatistics(@CurrentUser() userId: string): Promise<OrderStatistics> {
    return this.ordersService.getOrderStatistics(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get order by ID' })
  @ApiResponse({ status: 200, description: 'Returns order details' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async getOrderById(@Param('id') orderId: string, @CurrentUser() userId: string): Promise<OrderWithDetails> {
    return this.ordersService.getOrderById(orderId, userId);
  }

  @Get(':id/items')
  @ApiOperation({ summary: 'Get order items' })
  @ApiResponse({ status: 200, description: 'Returns order items' })
  async getOrderItems(@Param('id') orderId: string, @CurrentUser() userId: string): Promise<OrderItem[]> {
    return this.ordersService.getOrderItems(orderId, userId);
  }

  @Get(':id/track')
  @ApiOperation({ summary: 'Track order status' })
  @ApiResponse({ status: 200, description: 'Returns order tracking info' })
  async trackOrder(@Param('id') orderId: string, @CurrentUser() userId: string): Promise<OrderWithDetails> {
    return this.ordersService.trackOrder(orderId, userId);
  }

  @Post()
  @ApiOperation({ summary: 'Create new order (cart)' })
  @ApiResponse({ status: 201, description: 'Order created successfully' })
  @ApiResponse({ status: 404, description: 'Restaurant or delivery address not found' })
  async createOrder(@Body() createOrderDto: CreateOrderDto, @CurrentUser() userId: string): Promise<Order> {
    return this.ordersService.createOrder(createOrderDto, userId);
  }

  @Post('cart/items')
  @ApiOperation({ summary: 'Add item to cart' })
  @ApiResponse({ status: 201, description: 'Item added to cart successfully' })
  @ApiResponse({ status: 400, description: 'Cannot add items from different restaurants' })
  async addToCart(@Body() addOrderItemDto: AddOrderItemDto, @CurrentUser() userId: string): Promise<OrderItem> {
    return this.ordersService.addToCart(addOrderItemDto, userId);
  }

  @Post('checkout')
  @ApiOperation({ summary: 'Checkout cart' })
  @ApiResponse({ status: 200, description: 'Checkout successful' })
  @ApiResponse({ status: 404, description: 'Cart not found' })
  @ApiResponse({ status: 400, description: 'Cart is empty' })
  async checkout(@Body() checkoutDto: CheckoutDto, @CurrentUser() userId: string): Promise<Order> {
    return this.ordersService.checkout(checkoutDto, userId);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Cancel order' })
  @ApiResponse({ status: 200, description: 'Order cancelled successfully' })
  @ApiResponse({ status: 400, description: 'Cannot cancel order in current status' })
  async cancelOrder(
    @Param('id') orderId: string,
    @Body() cancelOrderDto: CancelOrderDto,
    @CurrentUser() userId: string,
  ): Promise<{ success: boolean }> {
    return this.ordersService.cancelOrder(orderId, userId, cancelOrderDto.reason);
  }

  @Post(':id/rate-restaurant')
  @ApiOperation({ summary: 'Rate restaurant for order' })
  @ApiResponse({ status: 201, description: 'Restaurant rated successfully' })
  @ApiResponse({ status: 400, description: 'Can only rate delivered orders' })
  async rateRestaurant(
    @Param('id') orderId: string,
    @Body() rateRestaurantDto: RateRestaurantDto,
    @CurrentUser() userId: string,
  ): Promise<{ success: boolean }> {
    return this.ordersService.rateRestaurant(orderId, rateRestaurantDto, userId);
  }

  @Post(':id/rate-driver')
  @ApiOperation({ summary: 'Rate driver for order' })
  @ApiResponse({ status: 201, description: 'Driver rated successfully' })
  @ApiResponse({ status: 400, description: 'Can only rate delivered orders' })
  async rateDriver(
    @Param('id') orderId: string,
    @Body() rateDriverDto: RateDriverDto,
    @CurrentUser() userId: string,
  ): Promise<{ success: boolean }> {
    return this.ordersService.rateDriver(orderId, rateDriverDto, userId);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update order' })
  @ApiResponse({ status: 200, description: 'Order updated successfully' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async updateOrder(
    @Param('id') orderId: string,
    @Body() updateOrderDto: UpdateOrderDto,
    @CurrentUser() userId: string,
  ): Promise<Order> {
    return this.ordersService.updateOrder(orderId, updateOrderDto, userId);
  }

  @Put('cart/items/:id')
  @ApiOperation({ summary: 'Update cart item' })
  @ApiResponse({ status: 200, description: 'Cart item updated successfully' })
  @ApiResponse({ status: 404, description: 'Cart item not found' })
  async updateCartItem(
    @Param('id') itemId: string,
    @Body() updateOrderItemDto: UpdateOrderItemDto,
    @CurrentUser() userId: string,
  ): Promise<OrderItem> {
    return this.ordersService.updateCartItem(itemId, updateOrderItemDto, userId);
  }

  @Delete('cart')
  @ApiOperation({ summary: 'Clear cart' })
  @ApiResponse({ status: 200, description: 'Cart cleared successfully' })
  async clearCart(@CurrentUser() userId: string): Promise<{ success: boolean }> {
    return this.ordersService.clearCart(userId);
  }

  @Delete('cart/items/:id')
  @ApiOperation({ summary: 'Remove item from cart' })
  @ApiResponse({ status: 200, description: 'Item removed from cart successfully' })
  @ApiResponse({ status: 404, description: 'Cart item not found' })
  async removeFromCart(@Param('id') itemId: string, @CurrentUser() userId: string): Promise<{ success: boolean }> {
    return this.ordersService.removeFromCart(itemId, userId);
  }
}
