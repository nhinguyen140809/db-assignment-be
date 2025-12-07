export interface Restaurant {
  restaurant_id: string;
  owner_id: string;
  name: string;
  phone?: string | null;
  email?: string | null;
  address_details?: string | null;
  longitude?: number | null;
  latitude?: number | null;
  registration_date?: Date;
  status: string;
  average_rating?: number | null;
  review_count?: number;
  is_favorite?: boolean;
}

export interface OperatingHour {
  dow: number; // Day of week: 0=Sunday, 1=Monday, etc.
  open_time: string;
  close_time?: string | null;
}

export interface RestaurantWithHours extends Restaurant {
  operating_hours: OperatingHour[];
}

export interface RestaurantReview {
  order_id: string;
  restaurant_id: string | null;
  customer_id: string | null;
  rating_point: number;
  comment?: string | null;
  created_at: Date;
  customer_name?: string;
}

export interface RestaurantSearchParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
  status?: string;
  minRating?: number;
  latitude?: number;
  longitude?: number;
  radius?: number; // in km
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
