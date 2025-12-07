export interface Order {
  order_id: string;
  customer_id: string;
  driver_id: string | null;
  restaurant_id: string;
  delivery_id: string;
  status: string;
  customer_note: string | null;
  delivery_fee: number | null;
  ordered_at: Date | null;
  delivered_at: Date | null;
}

export interface OrderItem {
  order_id: string;
  restaurant_id: string;
  item_id: string;
  quantity: number;
  price: number | null;
  note: string | null;
  item_name?: string;
  item_image?: string;
}

export interface OrderWithDetails extends Order {
  restaurant_name?: string;
  delivery_address?: string;
  customer_name?: string;
  driver_name?: string;
  items?: OrderItem[];
  subtotal?: number;
  total?: number;
}

export interface OrderSearchParams {
  page?: number;
  limit?: number;
  status?: string;
  restaurantId?: string;
  customerId?: string;
  driverId?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface OrderStatistics {
  total_orders: number;
  completed_orders: number;
  cancelled_orders: number;
  total_spent: number;
  average_order_value: number;
}
