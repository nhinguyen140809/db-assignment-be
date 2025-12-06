import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UserDetails, UpdateUserDetails, CreateUserDetails } from './interfaces/users.interface';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(createUserDetails: CreateUserDetails): Promise<UserDetails> {
    const { email, password, name } = createUserDetails;

    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new BadRequestException('User with this email already exists');
    }

    const saltRounds: number = 10;
    const passwordHash: string = await bcrypt.hash(password, saltRounds);

    const user = await this.prisma.user.create({
      data: {
        user_id: crypto.randomUUID(),
        email,
        password_hash: passwordHash,
        name,
        registration_date: new Date(),
        role: 'CUSTOMER',
      },
    });

    return {
      userId: user.user_id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      passwordHash: user.password_hash,
      registrationDate: user.registration_date,
    };
  }

  async getUser(userId: string): Promise<UserDetails> {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      userId: user.user_id,
      registrationDate: user.registration_date,
      passwordHash: user.password_hash,
      ...user,
    };
  }

  async getUserByEmail(email: string): Promise<UserDetails> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      userId: user.user_id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      passwordHash: user.password_hash,
      registrationDate: user.registration_date,
    };
  }

  // async updateUser(userId: string, updateUserDetails: UpdateUserDetails): Promise<void> {
  //   const existingUser = await this.prisma.user.findUnique({
  //     where: { userId },
  //   });

  //   if (!existingUser) {
  //     throw new NotFoundException('User not found');
  //   }

  //   await this.prisma.user.update({
  //     where: { userId },
  //     data: updateUserDetails,
  //   });
  // }

  // async deleteUser(userId: string): Promise<void> {
  //   const user = await this.prisma.user.findUnique({
  //     where: { userId },
  //   });

  //   if (!user) {
  //     throw new NotFoundException('User not found');
  //   }

  //   await this.prisma.user.delete({
  //     where: { userId },
  //   });
  // }

  async validatePassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}
