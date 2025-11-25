import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UserDetails, UpdateUserDetails, CreateUserDetails } from './interfaces/users.interface';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(createUserDetails: CreateUserDetails): Promise<UserDetails> {
    const { email, password, firstName, lastName } = createUserDetails;

    const existingUser = await this.prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new BadRequestException('User with this email already exists');
    }

    const saltRounds: number = 10;
    const passwordHash: string = await bcrypt.hash(password, saltRounds);

    const user = await this.prisma.users.create({
      data: {
        email,
        passwordHash,
        firstName,
        lastName,
      },
    });

    return user;
  }

  async getUser(userId: string): Promise<UserDetails> {
    const user = await this.prisma.users.findUnique({
      where: { userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async getUserByEmail(email: string): Promise<UserDetails> {
    const user = await this.prisma.users.findUnique({
      where: { email },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateUser(userId: string, updateUserDetails: UpdateUserDetails): Promise<void> {
    const existingUser = await this.prisma.users.findUnique({
      where: { userId },
    });

    if (!existingUser) {
      throw new NotFoundException('User not found');
    }

    await this.prisma.users.update({
      where: { userId },
      data: updateUserDetails,
    });
  }

  async deleteUser(userId: string): Promise<void> {
    const user = await this.prisma.users.findUnique({
      where: { userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    await this.prisma.users.delete({
      where: { userId },
    });
  }

  async validatePassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}
