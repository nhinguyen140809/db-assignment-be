import { Injectable, UnauthorizedException, NotFoundException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { AuthResponseDetails, JwtPayload, LoginDetails, RegisterDetails } from './interfaces';
import { UserDetails } from '../users/interfaces';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDetails: RegisterDetails): Promise<AuthResponseDetails> {
    const user = await this.usersService.createUser(registerDetails);

    const payload: JwtPayload = {
      userId: user.userId,
      email: user.email,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      authUser: {
        userId: user.userId,
        email: user.email,
        name: `${user.firstName} ${user.lastName}`,
        role: user.role,
        phone: user.phone,
      },
    };
  }

  async login(loginDetails: LoginDetails): Promise<AuthResponseDetails> {
    const { email, password } = loginDetails;
    const user = await this.usersService.getUserByEmail(email);
    if (!user) {
      throw new NotFoundException('User with this email does not exist');
    }

    const isPasswordValid = await this.usersService.validatePassword(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new BadRequestException('Password is incorrect');
    }

    const payload: JwtPayload = {
      userId: user.userId,
      email: user.email,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      authUser: {
        userId: user.userId,
        email: user.email,
        name: `${user.firstName} ${user.lastName}`,
        role: user.role,
        phone: user.phone,
      },
    };
  }

  async validateUser(userId: string): Promise<UserDetails> {
    const user = await this.usersService.getUser(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async refreshToken(userId: string): Promise<AuthResponseDetails> {
    const user = await this.usersService.getUser(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const payload: JwtPayload = {
      userId: user.userId,
      email: user.email,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      authUser: {
        userId: user.userId,
        email: user.email,
        name: `${user.firstName} ${user.lastName}`,
        role: user.role,
        phone: user.phone,
      },
    };
  }
}
