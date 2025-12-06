export interface AuthDetails {
  accessToken: string;
}

export interface LoginDetails {
  email: string;
  password: string;
}

export interface RegisterDetails {
  email: string;
  password: string;
  name: string;
}

export interface JwtPayload {
  userId: string;
  email: string;
  iat?: number;
  exp?: number;
}

export interface AuthResponseDetails {
  accessToken: string;
}
