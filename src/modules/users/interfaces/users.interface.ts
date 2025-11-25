export interface UserDetails {
  userId: string;
  email: string;
  passwordHash: string;
  firstName: string;
  lastName: string;
}

export interface CreateUserDetails {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

export interface UpdateUserDetails {
  email?: string;
  firstName?: string;
  lastName?: string;
}
