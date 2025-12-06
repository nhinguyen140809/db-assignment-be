export interface UserDetails {
  userId: string;
  email: string;
  phone?: string | null;
  name: string;
  role: string;
  passwordHash: string;
  registrationDate: Date;
}

export interface CreateUserDetails {
  email: string;
  password: string;
  name: string;
}

export interface UpdateUserDetails {
  email?: string;
  name?: string;
}
