import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService, Prisma } from '../../database/prisma.service';
import { CreateMenuItemDto, UpdateMenuItemDto, MenuItemSearchDto } from './dtos';
import { MenuItem, Category, PaginatedResponse, MenuItemSearchParams, FavoriteMenuSortOptions } from './interfaces';

@Injectable()
export class MenuService {
  async addCategory(name: string): Promise<{ name: string }> {
    // Check if category exists
    const existing = await this.prisma.category.findUnique({ where: { name } });
    if (existing) {
      throw new BadRequestException('Category already exists');
    }
    const category = await this.prisma.category.create({ data: { name } });
    return { name: category.name };
  }
  /**
   * Get all categories sorted alphabetically
   */
  async getCategories(): Promise<{ name: string }[]> {
    return this.prisma.category.findMany({
      orderBy: { name: 'asc' },
      select: { name: true },
    });
  }
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get all menu items with filters, sorting, and pagination
   */
  async getMenuItems(params: MenuItemSearchDto, userId?: string): Promise<PaginatedResponse<MenuItem>> {
    const {
      page = 1,
      limit = 10,
      sortBy = 'name',
      sortOrder = 'asc',
      search,
      category,
      restaurantId,
      minPrice,
      maxPrice,
      status,
    } = params;

    const skip = (page - 1) * limit;

    // Build where clause
    const where: Prisma.menu_itemWhereInput = {
      NOT: {
        status: 'DELETED',
      },
    };

    if (restaurantId) {
      where.restaurant_id = restaurantId;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [{ name: { contains: search } }, { description: { contains: search } }];
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) {
        where.price.gte = new Prisma.Decimal(minPrice);
      }
      if (maxPrice !== undefined) {
        where.price.lte = new Prisma.Decimal(maxPrice);
      }
    }

    if (category) {
      where.category_items = {
        some: {
          category_name: category,
        },
      };
    }

    // Build orderBy
    const orderBy: Prisma.menu_itemOrderByWithRelationInput = {};
    if (sortBy === 'name') {
      orderBy.name = sortOrder;
    } else if (sortBy === 'price') {
      orderBy.price = sortOrder;
    } else if (sortBy === 'status') {
      orderBy.status = sortOrder;
    } else {
      orderBy.name = sortOrder;
    }

    // Execute queries
    const [items, total] = await Promise.all([
      this.prisma.menu_item.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          restaurant: {
            select: {
              restaurant_id: true,
              name: true,
              address_details: true,
              phone: true,
              status: true,
            },
          },
          category_items: {
            select: {
              category_name: true,
            },
          },
          menu_item_favourite: userId
            ? {
                where: {
                  customer_id: userId,
                },
                select: {
                  customer_id: true,
                },
              }
            : false,
        },
      }),
      this.prisma.menu_item.count({ where }),
    ]);

    const formattedItems = items.map(item => this.formatMenuItem(item));

    return {
      data: formattedItems,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get menu items for a specific restaurant
   */
  async getRestaurantMenu(
    restaurantId: string,
    userId?: string,
    options?: { sortBy?: 'name' | 'price'; sortOrder?: 'asc' | 'desc' },
  ): Promise<MenuItem[]> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
    });

    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }

    const items = await this.prisma.menu_item.findMany({
      where: {
        restaurant_id: restaurantId,
        NOT: {
          status: 'DELETED',
        },
      },
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
        menu_item_favourite: userId
          ? {
              where: {
                customer_id: userId,
              },
              select: {
                customer_id: true,
              },
            }
          : false,
      },
    });

    const mappedItems = items.map(item => this.formatMenuItem(item));

    // Sort in memory
    const { sortBy = 'name', sortOrder = 'asc' } = options || {};
    return mappedItems.sort((a, b) => {
      if (sortBy === 'price') {
        return sortOrder === 'asc' ? a.price - b.price : b.price - a.price;
      } else {
        return sortOrder === 'asc' ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
      }
    });
  }

  /**
   * Get menu item by ID
   */
  async getMenuItemById(restaurantId: string, menuItemId: string, userId?: string): Promise<MenuItem> {
    const item = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
        menu_item_favourite: userId
          ? {
              where: {
                customer_id: userId,
              },
              select: {
                customer_id: true,
              },
            }
          : false,
      },
    });

    if (!item || item.status === 'DELETED') {
      throw new NotFoundException('Menu item not found');
    }

    return this.formatMenuItem(item);
  }

  /**
   * Get menu items by category
   */
  async getMenuItemsByCategory(category: string, userId?: string): Promise<MenuItem[]> {
    const categoryExists = await this.prisma.category.findUnique({
      where: { name: category },
    });

    if (!categoryExists) {
      throw new NotFoundException('Category not found');
    }

    const items = await this.prisma.menu_item.findMany({
      where: {
        NOT: {
          status: 'DELETED',
        },
        category_items: {
          some: {
            category_name: category,
          },
        },
      },
      orderBy: { name: 'asc' },
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
        menu_item_favourite: userId
          ? {
              where: {
                customer_id: userId,
              },
              select: {
                customer_id: true,
              },
            }
          : false,
      },
    });

    return items.map(item => this.formatMenuItem(item));
  }

  /**
   * Create menu item (restaurant owner only)
   */
  async createMenuItem(data: CreateMenuItemDto, userId: string): Promise<MenuItem> {
    // Check if user is the restaurant owner
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: data.restaurant_id },
    });
    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }
    if (restaurant.owner_id !== userId) {
      throw new ForbiddenException('You do not have permission to create menu items for this restaurant');
    }

    // Call the stored procedure to insert the menu item
    const result = await this.prisma.$queryRaw<Array<{ NewMenuItemID: string }>>`
      EXEC sp_InsertMenuItem
        @RestaurantID = ${data.restaurant_id},
        @Name = ${data.name},
        @Description = ${data.description ?? null},
        @Price = ${data.price},
        @Status = ${data.status || 'UNAVAILABLE'}
    `;
    const newMenuItemId = result[0]?.NewMenuItemID;
    if (!newMenuItemId) {
      throw new BadRequestException('Failed to create menu item');
    }

    // Fetch and return the created menu item
    const menuItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: data.restaurant_id,
          food_id: newMenuItemId,
        },
      },
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
      },
    });
    if (!menuItem) {
      throw new NotFoundException('Menu item created but not found');
    }
    return this.formatMenuItem(menuItem);
  }

  /**
   * Update menu item (restaurant owner only)
   */
  async updateMenuItem(
    restaurantId: string,
    menuItemId: string,
    data: UpdateMenuItemDto,
    userId: string,
  ): Promise<MenuItem> {
    // Check if menu item exists
    const existingItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
      include: {
        restaurant: true,
      },
    });

    if (!existingItem) {
      throw new NotFoundException('Menu item not found');
    }

    // Check if user is the restaurant owner
    if (existingItem.restaurant.owner_id !== userId) {
      throw new ForbiddenException('You do not have permission to update this menu item');
    }

    // Update menu item
    const updateData: Prisma.menu_itemUpdateInput = {};

    if (data.name !== undefined) updateData.name = data.name;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.price !== undefined) updateData.price = new Prisma.Decimal(data.price);
    if (data.status !== undefined) updateData.status = data.status;

    const updatedItem = await this.prisma.menu_item.update({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
      data: updateData,
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
      },
    });

    // Update categories if provided
    if (data.categories !== undefined) {
      await this.updateMenuItemCategories(restaurantId, menuItemId, data.categories);
    }

    const finalItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
      },
    });

    return this.formatMenuItem(finalItem!);
  }

  /**
   * Delete menu item (restaurant owner only)
   */
  async deleteMenuItem(restaurantId: string, menuItemId: string, userId: string): Promise<{ message: string }> {
    // Check if menu item exists
    const existingItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
      include: {
        restaurant: true,
      },
    });

    if (!existingItem) {
      throw new NotFoundException('Menu item not found');
    }

    // Check if user is the restaurant owner
    if (existingItem.restaurant.owner_id !== userId) {
      throw new ForbiddenException('You do not have permission to delete this menu item');
    }

    await this.prisma.menu_item.update({
      where: {
      restaurant_id_food_id: {
        restaurant_id: restaurantId,
        food_id: menuItemId,
      },
      },
      data: {
      status: 'DELETED',
      },
    });

    return { message: 'Menu item deleted successfully' };
  }

  /**
   * Toggle favorite menu item
   */
  async toggleFavoriteMenuItem(
    menuItemId: string,
    restaurantId: string,
    customerId: string,
  ): Promise<{ message: string; is_favorite: boolean }> {
    // Check if menu item exists
    const menuItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: restaurantId,
          food_id: menuItemId,
        },
      },
    });

    if (!menuItem) {
      throw new NotFoundException('Menu item not found');
    }

    // Check if already favorited
    const existingFavorite = await this.prisma.menu_item_favourite.findUnique({
      where: {
        customer_id_restaurant_id_menu_item_id: {
          customer_id: customerId,
          restaurant_id: restaurantId,
          menu_item_id: menuItemId,
        },
      },
    });

    if (existingFavorite) {
      // Remove from favorites
      await this.prisma.menu_item_favourite.delete({
        where: {
          customer_id_restaurant_id_menu_item_id: {
            customer_id: customerId,
            restaurant_id: restaurantId,
            menu_item_id: menuItemId,
          },
        },
      });
      return {
        message: 'Menu item removed from favorites',
        is_favorite: false,
      };
    } else {
      // Add to favorites
      await this.prisma.menu_item_favourite.create({
        data: {
          customer_id: customerId,
          restaurant_id: restaurantId,
          menu_item_id: menuItemId,
          favorited_at: new Date(),
        },
      });
      return { message: 'Menu item added to favorites', is_favorite: true };
    }
  }

  /**
   * Get favorite menu items for current user
   */
  async getFavoriteMenuItems(customerId: string, options?: FavoriteMenuSortOptions): Promise<MenuItem[]> {
    const sortBy = options?.sortBy || 'name';
    const sortOrder = options?.sortOrder || 'asc';

    const favorites = await this.prisma.menu_item_favourite.findMany({
      where: {
        customer_id: customerId,
      },
      include: {
        menu_item: {
          include: {
            restaurant: {
              select: {
                restaurant_id: true,
                name: true,
                address_details: true,
                phone: true,
                status: true,
              },
            },
            category_items: {
              select: {
                category_name: true,
              },
            },
          },
        },
      },
    });

    // Map and sort in memory since Prisma orderBy with nested relations can be tricky
    const mappedFavorites = favorites.map(fav => ({
      ...this.formatMenuItem(fav.menu_item),
      is_favorited: true,
    }));

    // Sort by the requested field
    return mappedFavorites.sort((a, b) => {
      if (sortBy === 'price') {
        return sortOrder === 'asc' ? a.price - b.price : b.price - a.price;
      } else {
        return sortOrder === 'asc' ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
      }
    });
  }

  /**
   * Search menu items
   */
  async searchMenuItems(query: string, userId?: string): Promise<MenuItem[]> {
    if (!query || query.trim().length === 0) {
      throw new BadRequestException('Search query is required');
    }

    const items = await this.prisma.menu_item.findMany({
      where: {
        OR: [{ name: { contains: query } }, { description: { contains: query } }],
      },
      orderBy: { name: 'asc' },
      take: 50, // Limit results
      include: {
        restaurant: {
          select: {
            restaurant_id: true,
            name: true,
            address_details: true,
            phone: true,
            status: true,
          },
        },
        category_items: {
          select: {
            category_name: true,
          },
        },
        menu_item_favourite: userId
          ? {
              where: {
                customer_id: userId,
              },
              select: {
                customer_id: true,
              },
            }
          : false,
      },
    });

    return items.map(item => this.formatMenuItem(item));
  }

  /**
   * Helper: Format menu item
   */
  private formatMenuItem(item: any): MenuItem {
    return {
      food_id: item.food_id,
      restaurant_id: item.restaurant_id,
      name: item.name,
      description: item.description,
      price: parseFloat(item.price.toString()),
      status: item.status,
      categories: item.category_items?.map((ci: any) => ci.category_name) || [],
      restaurant: item.restaurant,
      is_favorite: !!item.menu_item_favourite,
    };
  }

  /**
   * Helper: Update menu item categories
   */
  private async updateMenuItemCategories(
    restaurantId: string,
    menuItemId: string,
    categories: string[],
  ): Promise<void> {
    // Remove existing categories
    await this.prisma.category_items.deleteMany({
      where: {
        restaurant_id: restaurantId,
        menu_item_id: menuItemId,
      },
    });

    // Ensure all categories exist in the category table
    if (categories.length > 0) {
      // Create missing categories using raw SQL (no Prisma createMany)
      for (const name of categories) {
        // Escape single quotes in category name
        const safeName = name.replace(/'/g, "''");
        await this.prisma.$executeRawUnsafe(
          `IF NOT EXISTS (SELECT 1 FROM [category] WHERE [name] = N'${safeName}')
           INSERT INTO [category] ([name]) VALUES (N'${safeName}');`,
        );
      }

      // Now insert category_items
      await this.prisma.category_items.createMany({
        data: categories.map(categoryName => ({
          category_name: categoryName,
          restaurant_id: restaurantId,
          menu_item_id: menuItemId,
        })),
      });
    }
  }

  /**
   * Helper: Generate food ID
   */
  private async generateFoodId(restaurantId: string): Promise<string> {
    // Generate new food ID sequentially per restaurant (matching sp_InsertMenuItem logic)
    const result = await this.prisma.$queryRaw<Array<{ next_number: bigint }>>`
      SELECT ISNULL(MAX(CAST(SUBSTRING([food_id], 4, LEN([food_id])) AS BIGINT)), 0) + 1 as next_number
      FROM [menu_item] WITH (UPDLOCK, HOLDLOCK)
      WHERE [restaurant_id] = ${restaurantId}
    `;
    const nextNumber = result[0].next_number.toString();
    return 'FOO' + nextNumber.padStart(13, '0');
  }
}
