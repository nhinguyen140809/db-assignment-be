export interface MenuItem {
  food_id: string;
  restaurant_id: string;
  name: string;
  description?: string | null;
  price: number;
  status: string;
  categories?: string[];
  restaurant?: {
    restaurant_id: string;
    name: string;
    address_details?: string | null;
    phone?: string | null;
    status?: string;
  };
  is_favorite?: boolean;
}

export interface Category {
  name: string;
  itemCount?: number;
}

export interface MenuItemSearchParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
  category?: string;
  restaurantId?: string;
  minPrice?: number;
  maxPrice?: number;
  status?: string;
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
