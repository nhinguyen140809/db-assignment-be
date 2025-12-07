import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService, Prisma } from '../../database/prisma.service';
import { CreateRestaurantDto, UpdateRestaurantDto, RestaurantSearchDto } from './dtos';
import {
  Restaurant,
  RestaurantWithHours,
  RestaurantReview,
  RestaurantSearchParams,
  PaginatedResponse,
} from './interfaces';

@Injectable()
export class RestaurantService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get all restaurants with filters, sorting, and pagination
   */
  async getRestaurants(params: RestaurantSearchDto, userId?: string): Promise<PaginatedResponse<Restaurant>> {
    const {
      page = 1,
      limit = 10,
      sortBy = 'name',
      sortOrder = 'asc',
      search,
      status,
      minRating,
      latitude,
      longitude,
      radius,
    } = params;

    const skip = (page - 1) * limit;

    // Build where clause
    const where: Prisma.restaurantWhereInput = {};

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [
        { name: { contains: search } },
        { address_details: { contains: search } },
        { email: { contains: search } },
      ];
    }

    // Build orderBy
    const orderBy: Prisma.restaurantOrderByWithRelationInput = {};
    if (sortBy === 'name') {
      orderBy.name = sortOrder;
    } else if (sortBy === 'status') {
      orderBy.status = sortOrder;
    } else {
      orderBy.name = sortOrder;
    }

    // Execute queries
    const [restaurants, total] = await Promise.all([
      this.prisma.restaurant.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          operating_hour: true,
          restaurant_review: {
            select: {
              rating_point: true,
            },
          },
          menu_item: userId
            ? {
                select: {
                  menu_item_favourite: {
                    where: {
                      customer_id: userId,
                    },
                    take: 1,
                  },
                },
              }
            : false,
        },
      }),
      this.prisma.restaurant.count({ where }),
    ]);

    // Format results with average rating
    let formattedRestaurants = restaurants.map(restaurant => this.formatRestaurant(restaurant, userId));

    // Apply rating filter if specified
    if (minRating !== undefined) {
      formattedRestaurants = formattedRestaurants.filter(
        r => r.average_rating !== null && r.average_rating !== undefined && r.average_rating >= minRating,
      );
    }

    // Apply distance filter if specified
    if (latitude !== undefined && longitude !== undefined && radius !== undefined) {
      formattedRestaurants = formattedRestaurants.filter(r => {
        if (r.latitude === null || r.latitude === undefined || r.longitude === null || r.longitude === undefined)
          return false;
        const distance = this.calculateDistance(latitude, longitude, r.latitude, r.longitude);
        return distance <= radius;
      });
    }

    return {
      data: formattedRestaurants.slice(0, limit),
      meta: {
        total: formattedRestaurants.length,
        page,
        limit,
        totalPages: Math.ceil(formattedRestaurants.length / limit),
      },
    };
  }

  /**
   * Get restaurant by ID
   */
  async getRestaurantById(restaurantId: string, userId?: string): Promise<RestaurantWithHours> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
      include: {
        operating_hour: true,
        restaurant_review: {
          select: {
            rating_point: true,
          },
        },
        menu_item: userId
          ? {
              select: {
                menu_item_favourite: {
                  where: {
                    customer_id: userId,
                  },
                  take: 1,
                },
              },
            }
          : false,
      },
    });

    if (!restaurant) {
      throw new NotFoundException(`Restaurant with ID ${restaurantId} not found`);
    }

    return this.formatRestaurantWithHours(restaurant, userId);
  }

  /**
   * Get restaurant reviews
   */
  async getRestaurantReviews(
    restaurantId: string,
    page: number = 1,
    limit: number = 10,
  ): Promise<PaginatedResponse<RestaurantReview>> {
    // Check if restaurant exists
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
    });

    if (!restaurant) {
      throw new NotFoundException(`Restaurant with ID ${restaurantId} not found`);
    }

    const skip = (page - 1) * limit;

    const [reviews, total] = await Promise.all([
      this.prisma.restaurant_review.findMany({
        where: { restaurant_id: restaurantId },
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          customer: {
            select: {
              customer_id: true,
              user: {
                select: {
                  name: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.restaurant_review.count({ where: { restaurant_id: restaurantId } }),
    ]);

    const formattedReviews = reviews.map(review => ({
      order_id: review.order_id,
      customer_id: review.customer_id,
      restaurant_id: review.restaurant_id,
      rating_point: review.rating_point,
      comment: review.comment,
      created_at: review.created_at,
      customer_name: review.customer?.user?.name,
    }));

    return {
      data: formattedReviews,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get featured restaurants (high ratings)
   */
  async getFeaturedRestaurants(userId?: string): Promise<Restaurant[]> {
    const restaurants = await this.prisma.restaurant.findMany({
      where: {
        status: 'OPEN',
      },
      take: 10,
      include: {
        operating_hour: true,
        restaurant_review: {
          select: {
            rating_point: true,
          },
        },
        menu_item: userId
          ? {
              select: {
                menu_item_favourite: {
                  where: {
                    customer_id: userId,
                  },
                  take: 1,
                },
              },
            }
          : false,
      },
    });

    const formattedRestaurants = restaurants
      .map(restaurant => this.formatRestaurant(restaurant, userId))
      .filter(r => r.average_rating !== null && r.average_rating !== undefined && r.average_rating >= 4.0)
      .sort((a, b) => (b.average_rating || 0) - (a.average_rating || 0));

    return formattedRestaurants;
  }

  /**
   * Search restaurants with advanced filters
   */
  async searchRestaurants(params: RestaurantSearchParams, userId?: string): Promise<PaginatedResponse<Restaurant>> {
    return this.getRestaurants(params as RestaurantSearchDto, userId);
  }

  /**
   * Create a new restaurant
   */
  async createRestaurant(data: CreateRestaurantDto, ownerId: string): Promise<RestaurantWithHours> {
    // Generate new restaurant ID using RES_SQ sequence
    const result = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
      SELECT 'RES' + FORMAT(NEXT VALUE FOR dbo.RES_SQ, 'D13') as new_id
    `;
    const restaurantId = result[0].new_id;

    // Build data object without undefined fields
    const createData: any = {
      restaurant_id: restaurantId,
      name: data.name,
      phone: data.phone,
      email: data.email,
      address_details: data.address_details,
      longitude: data.longitude,
      latitude: data.latitude,
      registration_date: new Date(),
      status: data.status || 'OPEN',
    };

    console.log('Owner ID:', ownerId);
    if (ownerId) {
      createData.owner_id = ownerId;
    }
    if (data.operating_hours && data.operating_hours.length > 0) {
      createData.operating_hour = {
        create: data.operating_hours.map(oh => ({
          dow: oh.dow,
          open_time: oh.open_time,
          close_time: oh.close_time,
        })),
      };
    }

    // Create restaurant
    const restaurant = await this.prisma.restaurant.create({
      data: createData,
      include: {
        operating_hour: true,
        restaurant_review: {
          select: {
            rating_point: true,
          },
        },
      },
    });

    return this.formatRestaurantWithHours(restaurant, ownerId);
  }

  /**
   * Update restaurant
   */
  async updateRestaurant(
    restaurantId: string,
    data: UpdateRestaurantDto,
    userId: string,
  ): Promise<RestaurantWithHours> {
    // Check if restaurant exists
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
    });

    if (!restaurant) {
      throw new NotFoundException(`Restaurant with ID ${restaurantId} not found`);
    }

    // Check if user is the owner
    if (restaurant.owner_id !== userId) {
      throw new ForbiddenException('You do not have permission to update this restaurant');
    }

    // Update restaurant
    const updatedRestaurant = await this.prisma.restaurant.update({
      where: { restaurant_id: restaurantId },
      data: {
        name: data.name,
        phone: data.phone,
        email: data.email,
        address_details: data.address_details,
        longitude: data.longitude,
        latitude: data.latitude,
        status: data.status,
      },
      include: {
        operating_hour: true,
        restaurant_review: {
          select: {
            rating_point: true,
          },
        },
      },
    });

    // Update operating hours if provided
    if (data.operating_hours) {
      // Delete existing operating hours
      await this.prisma.operating_hour.deleteMany({
        where: { restaurant_id: restaurantId },
      });

      // Create new operating hours
      await this.prisma.operating_hour.createMany({
        data: data.operating_hours.map(oh => ({
          restaurant_id: restaurantId,
          dow: oh.dow,
          open_time: oh.open_time,
          close_time: oh.close_time,
        })),
      });
    }

    // Fetch updated restaurant with operating hours
    const finalRestaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
      include: {
        operating_hour: true,
        restaurant_review: {
          select: {
            rating_point: true,
          },
        },
      },
    });

    return this.formatRestaurantWithHours(finalRestaurant!, userId);
  }

  /**
   * Delete restaurant
   */
  async deleteRestaurant(restaurantId: string, userId: string): Promise<void> {
    // Check if restaurant exists
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
    });

    if (!restaurant) {
      throw new NotFoundException(`Restaurant with ID ${restaurantId} not found`);
    }

    // Check if user is the owner
    if (restaurant.owner_id !== userId) {
      throw new ForbiddenException('You do not have permission to delete this restaurant');
    }

    // Delete restaurant (cascade will handle related records)
    await this.prisma.restaurant.delete({
      where: { restaurant_id: restaurantId },
    });
  }

  /**
   * Toggle favorite restaurant (via menu items)
   */
  async toggleFavoriteRestaurant(restaurantId: string, userId: string): Promise<{ isFavorite: boolean }> {
    // Check if restaurant exists
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: restaurantId },
    });

    if (!restaurant) {
      throw new NotFoundException(`Restaurant with ID ${restaurantId} not found`);
    }

    // Check if customer has any favorited menu items from this restaurant
    const favoritedItems = await this.prisma.menu_item_favourite.findMany({
      where: {
        customer_id: userId,
        restaurant_id: restaurantId,
      },
    });

    if (favoritedItems.length > 0) {
      // Remove all favorites from this restaurant
      await this.prisma.menu_item_favourite.deleteMany({
        where: {
          customer_id: userId,
          restaurant_id: restaurantId,
        },
      });
      return { isFavorite: false };
    } else {
      // Find first available menu item and add it as favorite
      const firstMenuItem = await this.prisma.menu_item.findFirst({
        where: { restaurant_id: restaurantId },
      });

      if (!firstMenuItem) {
        throw new BadRequestException('Restaurant has no menu items to favorite');
      }

      await this.prisma.menu_item_favourite.create({
        data: {
          customer_id: userId,
          restaurant_id: restaurantId,
          menu_item_id: firstMenuItem.food_id,
          favorited_at: new Date(),
        },
      });
      return { isFavorite: true };
    }
  }

  /**
   * Get favorite restaurants
   */
  async getFavoriteRestaurants(
    userId: string,
    page: number = 1,
    limit: number = 10,
  ): Promise<PaginatedResponse<Restaurant>> {
    const skip = (page - 1) * limit;

    // Get distinct restaurant IDs from favorited menu items
    const favoritedMenuItems = await this.prisma.menu_item_favourite.findMany({
      where: { customer_id: userId },
      distinct: ['restaurant_id'],
      select: {
        restaurant_id: true,
      },
    });

    const restaurantIds = favoritedMenuItems.map(item => item.restaurant_id);

    if (restaurantIds.length === 0) {
      return {
        data: [],
        meta: {
          total: 0,
          page,
          limit,
          totalPages: 0,
        },
      };
    }

    const [restaurants, total] = await Promise.all([
      this.prisma.restaurant.findMany({
        where: {
          restaurant_id: {
            in: restaurantIds,
          },
        },
        skip,
        take: limit,
        include: {
          operating_hour: true,
          restaurant_review: {
            select: {
              rating_point: true,
            },
          },
          menu_item: {
            select: {
              menu_item_favourite: {
                where: {
                  customer_id: userId,
                },
                take: 1,
              },
            },
          },
        },
      }),
      this.prisma.restaurant.count({
        where: {
          restaurant_id: {
            in: restaurantIds,
          },
        },
      }),
    ]);

    const formattedRestaurants = restaurants.map(restaurant => this.formatRestaurant(restaurant, userId));

    return {
      data: formattedRestaurants,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Helper: Format restaurant with basic info
   */
  private formatRestaurant(restaurant: any, userId?: string): Restaurant {
    const ratings = restaurant.restaurant_review?.map((r: any) => r.rating_point) || [];
    const averageRating =
      ratings.length > 0 ? ratings.reduce((a: number, b: number) => a + b, 0) / ratings.length : null;

    // Check if restaurant is favorite by checking if any menu items are favorited
    let isFavorite = false;
    if (userId && restaurant.menu_item) {
      isFavorite = restaurant.menu_item.some(
        (item: any) => item.menu_item_favourite && item.menu_item_favourite.length > 0,
      );
    }

    return {
      restaurant_id: restaurant.restaurant_id,
      owner_id: restaurant.owner_id,
      name: restaurant.name,
      phone: restaurant.phone,
      email: restaurant.email,
      address_details: restaurant.address_details,
      longitude: restaurant.longitude !== null ? Number(restaurant.longitude) : null,
      latitude: restaurant.latitude !== null ? Number(restaurant.latitude) : null,
      registration_date: restaurant.registration_date,
      status: restaurant.status,
      average_rating: averageRating !== null ? Number(averageRating.toFixed(2)) : null,
      review_count: ratings.length,
      is_favorite: isFavorite,
    };
  }

  /**
   * Helper: Format restaurant with operating hours
   */
  private formatRestaurantWithHours(restaurant: any, userId?: string): RestaurantWithHours {
    const baseRestaurant = this.formatRestaurant(restaurant, userId);

    const operatingHours =
      restaurant.operating_hour?.map((oh: any) => ({
        dow: oh.dow,
        open_time: oh.open_time,
        close_time: oh.close_time,
      })) || [];

    return {
      ...baseRestaurant,
      operating_hours: operatingHours,
    };
  }

  /**
   * Helper: Calculate distance between two coordinates (Haversine formula)
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  /**
   * Helper: Convert degrees to radians
   */
  private toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }
}
