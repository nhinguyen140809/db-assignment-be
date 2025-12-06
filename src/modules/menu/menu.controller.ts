import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { MenuService } from './menu.service';
import { CreateMenuItemDto, UpdateMenuItemDto, MenuItemSearchDto, ToggleFavoriteDto } from './dtos';
import { JwtAuthGuard } from '../auth/guards';
import { Public } from '../../common/decorators';
import { CurrentUser } from '../../common/decorators';

@ApiTags('Menu')
@Controller()
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get('menu-items')
  @Public()
  @ApiOperation({ summary: 'Get all menu items with filters' })
  @ApiResponse({ status: 200, description: 'Returns paginated menu items' })
  async getMenuItems(@Query() searchDto: MenuItemSearchDto, @CurrentUser() user?: any) {
    return this.menuService.getMenuItems(searchDto, user?.userId);
  }

  @Get('restaurants/:restaurantId/menu')
  @Public()
  @ApiOperation({ summary: 'Get menu items for a specific restaurant' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiResponse({ status: 200, description: 'Returns restaurant menu items' })
  async getRestaurantMenu(@Param('restaurantId') restaurantId: string, @CurrentUser() user?: any) {
    return this.menuService.getRestaurantMenu(restaurantId, user?.userId);
  }

  @Get('menu-items/:restaurantId/:menuItemId')
  @Public()
  @ApiOperation({ summary: 'Get menu item by ID' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiParam({ name: 'menuItemId', description: 'Menu Item ID' })
  @ApiResponse({ status: 200, description: 'Returns menu item details' })
  @ApiResponse({ status: 404, description: 'Menu item not found' })
  async getMenuItemById(
    @Param('restaurantId') restaurantId: string,
    @Param('menuItemId') menuItemId: string,
    @CurrentUser() user?: any,
  ) {
    return this.menuService.getMenuItemById(restaurantId, menuItemId, user?.userId);
  }

  @Get('categories')
  @Public()
  @ApiOperation({ summary: 'Get all categories' })
  @ApiResponse({ status: 200, description: 'Returns all categories' })
  async getCategories() {
    return this.menuService.getCategories();
  }

  @Get('menu-items/category/:category')
  @Public()
  @ApiOperation({ summary: 'Get menu items by category' })
  @ApiParam({ name: 'category', description: 'Category name' })
  @ApiResponse({
    status: 200,
    description: 'Returns menu items in the category',
  })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async getMenuItemsByCategory(@Param('category') category: string, @CurrentUser() user?: any) {
    return this.menuService.getMenuItemsByCategory(category, user?.userId);
  }

  @Post('menu-items')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create menu item (restaurant owner only)' })
  @ApiResponse({
    status: 201,
    description: 'Menu item created successfully',
  })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Restaurant not found' })
  async createMenuItem(@Body() createDto: CreateMenuItemDto, @CurrentUser() user: any) {
    return this.menuService.createMenuItem(createDto, user.userId);
  }

  @Put('menu-items/:restaurantId/:menuItemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update menu item (restaurant owner only)' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiParam({ name: 'menuItemId', description: 'Menu Item ID' })
  @ApiResponse({
    status: 200,
    description: 'Menu item updated successfully',
  })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Menu item not found' })
  async updateMenuItem(
    @Param('restaurantId') restaurantId: string,
    @Param('menuItemId') menuItemId: string,
    @Body() updateDto: UpdateMenuItemDto,
    @CurrentUser() user: any,
  ) {
    return this.menuService.updateMenuItem(restaurantId, menuItemId, updateDto, user.userId);
  }

  @Delete('menu-items/:restaurantId/:menuItemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete menu item (restaurant owner only)' })
  @ApiParam({ name: 'restaurantId', description: 'Restaurant ID' })
  @ApiParam({ name: 'menuItemId', description: 'Menu Item ID' })
  @ApiResponse({
    status: 200,
    description: 'Menu item deleted successfully',
  })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Menu item not found' })
  async deleteMenuItem(
    @Param('restaurantId') restaurantId: string,
    @Param('menuItemId') menuItemId: string,
    @CurrentUser() user: any,
  ) {
    return this.menuService.deleteMenuItem(restaurantId, menuItemId, user.userId);
  }

  @Post('menu-items/:menuItemId/favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Toggle favorite menu item' })
  @ApiParam({ name: 'menuItemId', description: 'Menu Item ID' })
  @ApiResponse({
    status: 200,
    description: 'Favorite status toggled successfully',
  })
  @ApiResponse({ status: 404, description: 'Menu item not found' })
  async toggleFavoriteMenuItem(
    @Param('menuItemId') menuItemId: string,
    @Body() toggleDto: ToggleFavoriteDto,
    @CurrentUser() user: any,
  ) {
    return this.menuService.toggleFavoriteMenuItem(menuItemId, toggleDto.restaurant_id, user.userId);
  }

  @Get('menu-items/favorites')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get favorite menu items for current user' })
  @ApiResponse({
    status: 200,
    description: 'Returns favorite menu items',
  })
  async getFavoriteMenuItems(@CurrentUser() user: any) {
    return this.menuService.getFavoriteMenuItems(user.userId);
  }

  @Get('menu-items/search')
  @Public()
  @ApiOperation({ summary: 'Search menu items' })
  @ApiQuery({ name: 'query', description: 'Search query' })
  @ApiResponse({ status: 200, description: 'Returns matching menu items' })
  @ApiResponse({ status: 400, description: 'Search query is required' })
  async searchMenuItems(@Query('query') query: string, @CurrentUser() user?: any) {
    return this.menuService.searchMenuItems(query, user?.userId);
  }
}
