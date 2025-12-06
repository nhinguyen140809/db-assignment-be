import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UserDetails, UpdateUserDetails, CreateUserDetails } from './interfaces/users.interface';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(createUserDetails: CreateUserDetails): Promise<UserDetails> {
    const { email, password, firstName, lastName } = createUserDetails;

    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new BadRequestException('User with this email already exists');
    }

    const saltRounds: number = 10;
    const passwordHash: string = await bcrypt.hash(password, saltRounds);

    // Generate user_id
    const userId = await this.generateUserId();

    const user = await this.prisma.user.create({
      data: {
        user_id: userId,
        email,
        password_hash: passwordHash,
        name: `${firstName} ${lastName}`,
        registration_date: new Date(),
      },
    });

    return this.mapToUserDetails(user);
  }

  async getUser(userId: string): Promise<UserDetails> {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.mapToUserDetails(user);
  }

  async getUserByEmail(email: string): Promise<UserDetails> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.mapToUserDetails(user);
  }

  async updateUser(userId: string, updateUserDetails: UpdateUserDetails): Promise<void> {
    const existingUser = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });

    if (!existingUser) {
      throw new NotFoundException('User not found');
    }

    const updateData: any = {};
    if (updateUserDetails.email !== undefined) updateData.email = updateUserDetails.email;
    if (updateUserDetails.firstName || updateUserDetails.lastName) {
      const firstName = updateUserDetails.firstName || existingUser.name.split(' ')[0];
      const lastName = updateUserDetails.lastName || existingUser.name.split(' ').slice(1).join(' ');
      updateData.name = `${firstName} ${lastName}`;
    }

    await this.prisma.user.update({
      where: { user_id: userId },
      data: updateData,
    });
  }

  async deleteUser(userId: string): Promise<void> {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    await this.prisma.user.delete({
      where: { user_id: userId },
    });
  }

  async validatePassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  /**
   * Helper: Map Prisma user model to UserDetails interface
   */
  private mapToUserDetails(user: any): UserDetails {
    const nameParts = user.name.split(' ');
    const firstName = nameParts[0] || '';
    const lastName = nameParts.slice(1).join(' ') || '';

    return {
      userId: user.user_id,
      email: user.email || '',
      passwordHash: user.password_hash,
      firstName,
      lastName,
    };
  }

  /**
   * Helper: Generate user ID
   */
  private async generateUserId(): Promise<string> {
    const prefix = 'US';
    const result = await this.prisma.$queryRaw<Array<{ next_val: bigint }>>`
      SELECT NEXT VALUE FOR dbo.pk_sequence AS next_val
    `;
    const nextVal = result[0].next_val.toString().padStart(14, '0');
    return `${prefix}${nextVal}`;
  }
}
