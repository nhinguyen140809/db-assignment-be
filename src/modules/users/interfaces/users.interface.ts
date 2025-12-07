export interface UserDetails {
  userId: string;
  email: string;
  passwordHash: string;
  firstName: string;
  lastName: string;
  role?: 'customer' | 'driver' | 'restaurant_owner';
  phone?: string;
}

export interface CreateUserDetails {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: 'customer' | 'driver' | 'restaurant_owner';
  phone?: string;
  recommendedCustomerId?: string;
}

export interface UpdateUserDetails {
  email?: string;
  firstName?: string;
  lastName?: string;
}
