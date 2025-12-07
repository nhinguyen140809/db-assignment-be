import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService, Prisma } from '../../database/prisma.service';
import {
  CreateOrderDto,
  UpdateOrderDto,
  AddOrderItemDto,
  UpdateOrderItemDto,
  OrderSearchDto,
  CheckoutDto,
  RateRestaurantDto,
  RateDriverDto,
} from './dtos';
import { Order, OrderItem, OrderWithDetails, PaginatedResponse, OrderStatistics } from './interfaces';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get all orders with filters, sorting, and pagination
   */
  async getOrders(
    params: OrderSearchDto,
    userId: string,
    userRole?: string,
  ): Promise<PaginatedResponse<OrderWithDetails>> {
    const { page = 1, limit = 10, sortBy = 'ordered_at', sortOrder = 'desc', status, restaurantId } = params;

    const skip = (page - 1) * limit;

    // Build where clause based on user role
    const where: Prisma.orderWhereInput = {};

    if (status) {
      where.status = status;
    }

    if (restaurantId) {
      where.restaurant_id = restaurantId;
    }

    // Filter based on user role
    // If customer: show only their orders
    // If driver: show orders assigned to them
    // If restaurant owner: show orders for their restaurants
    // For now, show user's orders as customer
    where.customer_id = userId;

    // Build orderBy
    const orderBy: Prisma.orderOrderByWithRelationInput = {};
    if (sortBy === 'ordered_at') {
      orderBy.ordered_at = sortOrder;
    } else if (sortBy === 'status') {
      orderBy.status = sortOrder;
    } else {
      orderBy.ordered_at = sortOrder;
    }

    // Execute queries
    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          restaurant: {
            select: {
              name: true,
            },
          },
          delivery_address: {
            select: {
              details: true,
            },
          },
          order_items: {
            include: {
              menu_item: {
                select: {
                  name: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.order.count({ where }),
    ]);

    const formattedOrders = orders.map(order => this.formatOrderWithDetails(order));

    return {
      data: formattedOrders,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get order by ID with full details
   */
  async getOrderById(orderId: string, userId: string): Promise<OrderWithDetails> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
      include: {
        restaurant: {
          select: {
            name: true,
            phone: true,
          },
        },
        delivery_address: {
          select: {
            recipient_name: true,
            phone: true,
            details: true,
          },
        },
        order_items: {
          include: {
            menu_item: {
              select: {
                name: true,
              },
            },
          },
        },
        driver: {
          select: {
            user: {
              select: {
                name: true,
                phone: true,
              },
            },
          },
        },
      },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${orderId} not found`);
    }

    // Check if user has permission to view this order
    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to view this order');
    }

    return this.formatOrderWithDetails(order);
  }

  /**
   * Get current user's orders
   */
  async getMyOrders(userId: string, status?: string): Promise<OrderWithDetails[]> {
    const where: Prisma.orderWhereInput = {
      customer_id: userId,
      status: { not: 'IN_CART' }, // Exclude cart
    };

    if (status) {
      where.status = status;
    }

    const orders = await this.prisma.order.findMany({
      where,
      orderBy: { ordered_at: 'desc' },
      include: {
        restaurant: {
          select: {
            name: true,
          },
        },
        delivery_address: {
          select: {
            details: true,
          },
        },
        order_items: {
          include: {
            menu_item: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    return orders.map(order => this.formatOrderWithDetails(order));
  }

  /**
   * Get current cart (order with IN_CART status)
   */
  async getCart(userId: string): Promise<OrderWithDetails | null> {
    const cart = await this.prisma.order.findFirst({
      where: {
        customer_id: userId,
        status: 'IN_CART',
      },
      include: {
        restaurant: {
          select: {
            name: true,
          },
        },
        order_items: {
          include: {
            menu_item: {
              select: {
                name: true,
                price: true,
              },
            },
          },
        },
      },
    });

    if (!cart) {
      return null;
    }

    return this.formatOrderWithDetails(cart);
  }

  /**
   * Create a new order (cart)
   */
  async createOrder(data: CreateOrderDto, userId: string): Promise<Order> {
    // Generate new order ID using ORD_SQ sequence
    const result = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
      SELECT 'ORD' + FORMAT(NEXT VALUE FOR dbo.ORD_SQ, 'D13') as new_id
    `;
    const orderId = result[0].new_id;

    // Check if restaurant exists
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { restaurant_id: data.restaurant_id },
    });

    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }

    // Check if delivery address exists and belongs to user
    const deliveryAddress = await this.prisma.delivery_address.findUnique({
      where: {
        address_id_customer_id: {
          address_id: data.delivery_id,
          customer_id: userId,
        },
      },
    });

    if (!deliveryAddress) {
      throw new NotFoundException('Delivery address not found');
    }

    const order = await this.prisma.order.create({
      data: {
        order_id: orderId,
        customer_id: userId,
        restaurant_id: data.restaurant_id,
        delivery_id: data.delivery_id,
        customer_note: data.customer_note,
        status: 'IN_CART',
      },
    });

    return this.formatOrder(order);
  }

  /**
   * Update order
   */
  async updateOrder(orderId: string, data: UpdateOrderDto, userId: string): Promise<Order> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${orderId} not found`);
    }

    // Check permissions
    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to update this order');
    }

    const updatedOrder = await this.prisma.order.update({
      where: { order_id: orderId },
      data: {
        status: data.status,
        driver_id: data.driver_id,
        customer_note: data.customer_note,
        delivery_fee: data.delivery_fee,
      },
    });

    return this.formatOrder(updatedOrder);
  }

  /**
   * Cancel order
   */
  async cancelOrder(orderId: string, userId: string, reason?: string): Promise<{ success: boolean }> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${orderId} not found`);
    }

    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to cancel this order');
    }

    // Can only cancel orders that are not delivered or already cancelled
    if (['DELIVERED', 'CANCELLED'].includes(order.status)) {
      throw new BadRequestException('Cannot cancel order in current status');
    }

    await this.prisma.order.update({
      where: { order_id: orderId },
      data: {
        status: 'CANCELLED',
        customer_note: reason || order.customer_note,
      },
    });

    return { success: true };
  }

  /**
   * Add item to cart
   */
  async addToCart(data: AddOrderItemDto, userId: string): Promise<OrderItem> {
    // Ensure user has at least one delivery address
    const addresses = await this.prisma.delivery_address.findMany({
      where: { customer_id: userId },
      orderBy: { address_id: 'desc' },
    });

    if (!addresses || addresses.length === 0) {
      throw new BadRequestException('Please add a delivery address in your profile before ordering.');
    }

    const defaultAddressId = addresses[0].address_id;

    // Get or create cart
    let cart = await this.prisma.order.findFirst({
      where: {
        customer_id: userId,
        status: 'IN_CART',
      },
    });

    // If no cart exists, create one with the first delivery address
    if (!cart) {
      const result = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
        SELECT 'ORD' + FORMAT(NEXT VALUE FOR dbo.ORD_SQ, 'D13') as new_id
      `;
      const orderId = result[0].new_id;

      cart = await this.prisma.order.create({
        data: {
          order_id: orderId,
          customer_id: userId,
          restaurant_id: data.restaurant_id,
          delivery_id: defaultAddressId,
          status: 'IN_CART',
        },
      });
    }

    // Check if adding from different restaurant
    if (cart.restaurant_id !== data.restaurant_id) {
      throw new BadRequestException('Cannot add items from different restaurants to cart');
    }

    // Get menu item details
    const menuItem = await this.prisma.menu_item.findUnique({
      where: {
        restaurant_id_food_id: {
          restaurant_id: data.restaurant_id,
          food_id: data.item_id,
        },
      },
    });

    if (!menuItem) {
      throw new NotFoundException('Menu item not found');
    }

    // Check if item already in cart
    const existingItem = await this.prisma.order_items.findUnique({
      where: {
        order_id_item_id_restaurant_id: {
          order_id: cart.order_id,
          item_id: data.item_id,
          restaurant_id: data.restaurant_id,
        },
      },
    });

    let orderItem;
    if (existingItem) {
      // Update quantity
      orderItem = await this.prisma.order_items.update({
        where: {
          order_id_item_id_restaurant_id: {
            order_id: cart.order_id,
            item_id: data.item_id,
            restaurant_id: data.restaurant_id,
          },
        },
        data: {
          quantity: existingItem.quantity + data.quantity,
          note: data.note || existingItem.note,
        },
        include: {
          menu_item: {
            select: {
              name: true,
            },
          },
        },
      });
    } else {
      // Add new item
      orderItem = await this.prisma.order_items.create({
        data: {
          order_id: cart.order_id,
          restaurant_id: data.restaurant_id,
          item_id: data.item_id,
          quantity: data.quantity,
          price: menuItem.price,
          note: data.note,
        },
        include: {
          menu_item: {
            select: {
              name: true,
            },
          },
        },
      });
    }

    return this.formatOrderItem(orderItem);
  }

  /**
   * Update cart item
   */
  async updateCartItem(itemId: string, data: UpdateOrderItemDto, userId: string): Promise<OrderItem> {
    // Find the cart item
    const cartItem = await this.prisma.order_items.findFirst({
      where: {
        item_id: itemId,
        order: {
          customer_id: userId,
          status: 'IN_CART',
        },
      },
      include: {
        order: true,
      },
    });

    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    const updatedItem = await this.prisma.order_items.update({
      where: {
        order_id_item_id_restaurant_id: {
          order_id: cartItem.order_id,
          item_id: itemId,
          restaurant_id: cartItem.restaurant_id,
        },
      },
      data: {
        quantity: data.quantity,
        note: data.note,
      },
      include: {
        menu_item: {
          select: {
            name: true,
          },
        },
      },
    });

    return this.formatOrderItem(updatedItem);
  }

  /**
   * Remove item from cart
   */
  async removeFromCart(itemId: string, userId: string): Promise<{ success: boolean }> {
    // Find the cart item
    const cartItem = await this.prisma.order_items.findFirst({
      where: {
        item_id: itemId,
        order: {
          customer_id: userId,
          status: 'IN_CART',
        },
      },
    });

    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    await this.prisma.order_items.delete({
      where: {
        order_id_item_id_restaurant_id: {
          order_id: cartItem.order_id,
          item_id: itemId,
          restaurant_id: cartItem.restaurant_id,
        },
      },
    });

    return { success: true };
  }

  /**
   * Clear cart
   */
  async clearCart(userId: string): Promise<{ success: boolean }> {
    const cart = await this.prisma.order.findFirst({
      where: {
        customer_id: userId,
        status: 'IN_CART',
      },
    });

    if (cart) {
      // Delete all items
      await this.prisma.order_items.deleteMany({
        where: { order_id: cart.order_id },
      });

      // Delete the cart order
      await this.prisma.order.delete({
        where: { order_id: cart.order_id },
      });
    }

    return { success: true };
  }

  /**
   * Checkout (convert cart to pending order)
   */
  async checkout(data: CheckoutDto, userId: string): Promise<Order> {
    const cart = await this.prisma.order.findFirst({
      where: {
        customer_id: userId,
        status: 'IN_CART',
      },
      include: {
        order_items: true,
      },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    if (!cart.order_items || cart.order_items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    // Verify delivery address belongs to user
    const deliveryAddress = await this.prisma.delivery_address.findUnique({
      where: {
        address_id_customer_id: {
          address_id: data.delivery_id,
          customer_id: userId,
        },
      },
    });

    if (!deliveryAddress) {
      throw new NotFoundException('Delivery address not found');
    }

    // Verify payment method belongs to user
    const paymentMethod = await this.prisma.payment_method.findUnique({
      where: {
        payment_id: data.payment_method_id,
      },
    });

    if (!paymentMethod || paymentMethod.customer_id !== userId) {
      throw new NotFoundException('Payment method not found');
    }

    // Calculate delivery fee randomly between 10 and 20 (same unit as column)
    const minFee = 10;
    const maxFee = 20;
    const randomFee = Math.floor(Math.random() * (maxFee - minFee + 1)) + minFee;
    const deliveryFee = new Prisma.Decimal(randomFee);

    // Update order status
    const order = await this.prisma.order.update({
      where: { order_id: cart.order_id },
      data: {
        delivery_id: data.delivery_id,
        status: 'PLACED',
        delivery_fee: deliveryFee,
        ordered_at: new Date(),
      },
    });

    // Create order payment record
    const paymentResult = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
      SELECT 'OPM' + FORMAT(NEXT VALUE FOR dbo.OPM_SQ, 'D13') as new_id
    `;
    const orderPaymentId = paymentResult[0].new_id;

    await this.prisma.order_payments.create({
      data: {
        order_payment_id: orderPaymentId,
        order_id: cart.order_id,
        payment_method_id: data.payment_method_id,
        status: 'PENDING',
        created_at: new Date(),
      },
    });

    return this.formatOrder(order);
  }

  /**
   * Get order items
   */
  async getOrderItems(orderId: string, userId: string): Promise<OrderItem[]> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to view this order');
    }

    const items = await this.prisma.order_items.findMany({
      where: { order_id: orderId },
      include: {
        menu_item: {
          select: {
            name: true,
          },
        },
      },
    });

    return items.map(item => this.formatOrderItem(item));
  }

  /**
   * Track order status
   */
  async trackOrder(orderId: string, userId: string): Promise<OrderWithDetails> {
    return this.getOrderById(orderId, userId);
  }

  /**
   * Rate restaurant
   */
  async rateRestaurant(orderId: string, data: RateRestaurantDto, userId: string): Promise<{ success: boolean }> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to rate this order');
    }

    if (order.status !== 'DELIVERED') {
      throw new BadRequestException('Can only rate delivered orders');
    }

    // Check if review already exists
    const existingReview = await this.prisma.restaurant_review.findUnique({
      where: { order_id: orderId },
    });

    if (existingReview) {
      throw new BadRequestException('Order already rated');
    }

    await this.prisma.restaurant_review.create({
      data: {
        order_id: orderId,
        restaurant_id: order.restaurant_id,
        customer_id: userId,
        rating_point: data.rating_point,
        comment: data.comment,
        created_at: new Date(),
      },
    });

    return { success: true };
  }

  /**
   * Rate driver
   */
  async rateDriver(orderId: string, data: RateDriverDto, userId: string): Promise<{ success: boolean }> {
    const order = await this.prisma.order.findUnique({
      where: { order_id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.customer_id !== userId) {
      throw new ForbiddenException('You do not have permission to rate this order');
    }

    if (order.status !== 'DELIVERED') {
      throw new BadRequestException('Can only rate delivered orders');
    }

    if (!order.driver_id) {
      throw new BadRequestException('Order has no driver assigned');
    }

    // Check if review already exists
    const existingReview = await this.prisma.driver_review.findUnique({
      where: { order_id: orderId },
    });

    if (existingReview) {
      throw new BadRequestException('Driver already rated');
    }

    await this.prisma.driver_review.create({
      data: {
        order_id: orderId,
        driver_id: order.driver_id,
        customer_id: userId,
        rating_point: data.rating_point,
        comment: data.comment,
        created_at: new Date(),
      },
    });

    return { success: true };
  }

  /**
   * Get order statistics
   */
  async getOrderStatistics(userId: string): Promise<OrderStatistics> {
    const orders = await this.prisma.order.findMany({
      where: {
        customer_id: userId,
        status: { not: 'IN_CART' },
      },
      include: {
        order_items: true,
      },
    });

    const completedOrders = orders.filter(o => o.status === 'DELIVERED');
    const cancelledOrders = orders.filter(o => o.status === 'CANCELLED');

    const totalSpent = completedOrders.reduce((sum, order) => {
      const itemsTotal = order.order_items.reduce(
        (itemSum, item) => itemSum + (item.price ? Number(item.price) * item.quantity : 0),
        0,
      );
      const deliveryFee = order.delivery_fee ? Number(order.delivery_fee) : 0;
      return sum + itemsTotal + deliveryFee;
    }, 0);

    return {
      total_orders: orders.length,
      completed_orders: completedOrders.length,
      cancelled_orders: cancelledOrders.length,
      total_spent: totalSpent,
      average_order_value: completedOrders.length > 0 ? totalSpent / completedOrders.length : 0,
    };
  }

  /**
   * Helper: Format order
   */
  private formatOrder(order: any): Order {
    return {
      order_id: order.order_id,
      customer_id: order.customer_id,
      driver_id: order.driver_id,
      restaurant_id: order.restaurant_id,
      delivery_id: order.delivery_id,
      status: order.status,
      customer_note: order.customer_note,
      delivery_fee: order.delivery_fee ? Number(order.delivery_fee) : null,
      ordered_at: order.ordered_at,
      delivered_at: order.delivered_at,
    };
  }

  /**
   * Helper: Format order with details
   */
  private formatOrderWithDetails(order: any): OrderWithDetails {
    const baseOrder = this.formatOrder(order);

    const items = order.order_items?.map((item: any) => this.formatOrderItem(item)) || [];
    const subtotal = items.reduce((sum, item) => sum + (item.price || 0) * item.quantity, 0);
    const deliveryFee = order.delivery_fee ? Number(order.delivery_fee) : 0;

    return {
      ...baseOrder,
      restaurant_name: order.restaurant?.name,
      delivery_address: order.delivery_address?.details,
      driver_name: order.driver?.user?.name,
      items,
      subtotal,
      total: subtotal + deliveryFee,
    };
  }

  /**
   * Helper: Format order item
   */
  private formatOrderItem(item: any): OrderItem {
    return {
      order_id: item.order_id,
      restaurant_id: item.restaurant_id,
      item_id: item.item_id,
      quantity: item.quantity,
      price: item.price ? Number(item.price) : null,
      note: item.note,
      item_name: item.menu_item?.name,
    };
  }
}
