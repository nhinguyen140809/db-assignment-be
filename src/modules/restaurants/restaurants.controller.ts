import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { RestaurantService } from './restaurants.service';
import { CreateRestaurantDto, UpdateRestaurantDto, RestaurantSearchDto } from './dtos';
import { JwtAuthGuard } from '../auth/guards';
import { Public } from '../../common/decorators';
import { CurrentUser } from '../../common/decorators';

@ApiTags('Restaurants')
@Controller('restaurants')
export class RestaurantController {
  constructor(private readonly restaurantService: RestaurantService) {}

  @Get()
  @Public()
  @ApiOperation({ summary: 'Get all restaurants with filters' })
  @ApiResponse({ status: 200, description: 'Returns paginated restaurants' })
  async getRestaurants(@Query() searchDto: RestaurantSearchDto, @CurrentUser() user?: any) {
    return this.restaurantService.getRestaurants(searchDto, user?.userId);
  }

  @Get('featured')
  @Public()
  @ApiOperation({ summary: 'Get featured restaurants (high ratings)' })
  @ApiResponse({ status: 200, description: 'Returns featured restaurants' })
  async getFeaturedRestaurants(@CurrentUser() user?: any) {
    return this.restaurantService.getFeaturedRestaurants(user?.userId);
  }

  @Get('search')
  @Public()
  @ApiOperation({ summary: 'Search restaurants with advanced filters' })
  @ApiResponse({ status: 200, description: 'Returns search results' })
  async searchRestaurants(@Query() searchDto: RestaurantSearchDto, @CurrentUser() user?: any) {
    return this.restaurantService.searchRestaurants(searchDto, user?.userId);
  }

  @Get('favorites')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get favorite restaurants for current user' })
  @ApiResponse({ status: 200, description: 'Returns favorite restaurants' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getFavoriteRestaurants(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
    @CurrentUser() user: any,
  ) {
    return this.restaurantService.getFavoriteRestaurants(user.userId, page, limit);
  }

  @Get(':restaurantId')
  @Public()
  @ApiOperation({ summary: 'Get restaurant by ID' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Returns restaurant details' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  async getRestaurantById(@Param('restaurantId') restaurantId: string, @CurrentUser() userId?: string) {
    return this.restaurantService.getRestaurantById(restaurantId, userId);
  }

  @Get(':restaurantId/reviews')
  @Public()
  @ApiOperation({ summary: 'Get restaurant reviews' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Returns restaurant reviews' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getRestaurantReviews(
    @Param('restaurantId') restaurantId: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
  ) {
    return this.restaurantService.getRestaurantReviews(restaurantId, page, limit);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new restaurant (owner only)' })
  @ApiResponse({ status: 201, description: 'Restaurant created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async createRestaurant(@Body() createDto: CreateRestaurantDto, @CurrentUser() userId: string) {
    return this.restaurantService.createRestaurant(createDto, userId);
  }

  @Put(':restaurantId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update restaurant (owner only)' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Restaurant updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  async updateRestaurant(
    @Param('restaurantId') restaurantId: string,
    @Body() updateDto: UpdateRestaurantDto,
    @CurrentUser() userId: string,
  ) {
    return this.restaurantService.updateRestaurant(restaurantId, updateDto, userId);
  }

  @Delete(':restaurantId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete restaurant (owner only)' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Restaurant deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  async deleteRestaurant(@Param('restaurantId') restaurantId: string, @CurrentUser() userId: string) {
    return this.restaurantService.deleteRestaurant(restaurantId, userId);
  }

  @Post(':restaurantId/favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Toggle favorite restaurant' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Favorite status toggled successfully' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  async toggleFavoriteRestaurant(@Param('restaurantId') restaurantId: string, @CurrentUser() user: any) {
    return this.restaurantService.toggleFavoriteRestaurant(restaurantId, user.userId);
  }
}
