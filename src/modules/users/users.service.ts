import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UserDetails, UpdateUserDetails, CreateUserDetails } from './interfaces/users.interface';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(createUserDetails: CreateUserDetails): Promise<UserDetails> {
    const { email, password, firstName, lastName, role, phone, recommendedCustomerId } = createUserDetails;

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

    // Create user and corresponding role record in a transaction
    const user = await this.prisma.$transaction(async tx => {
      // Create base user
      const newUser = await tx.user.create({
        data: {
          user_id: userId,
          email,
          password_hash: passwordHash,
          name: `${firstName} ${lastName}`,
          phone,
          registration_date: new Date(),
        },
      });

      // Create role-specific record
      switch (role) {
        case 'customer':
          await tx.customer.create({
            data: {
              customer_id: userId,
              recommended_customer_id: recommendedCustomerId || null,
            },
          });
          break;

        case 'driver':
          await tx.driver.create({
            data: {
              driver_id: userId,
              driver_license_id: '', // Will be updated later
              status: 'OFFLINE',
            },
          });
          break;

        case 'restaurant_owner':
          await tx.restaurant_owner.create({
            data: {
              owner_id: userId,
            },
          });
          break;
      }

      return newUser;
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

    // Determine role by checking role tables
    let role: 'customer' | 'driver' | 'restaurant_owner' | undefined;

    const [customer, driver, owner] = await Promise.all([
      this.prisma.customer.findUnique({ where: { customer_id: userId } }),
      this.prisma.driver.findUnique({ where: { driver_id: userId } }),
      this.prisma.restaurant_owner.findUnique({ where: { owner_id: userId } }),
    ]);

    if (customer) role = 'customer';
    else if (driver) role = 'driver';
    else if (owner) role = 'restaurant_owner';

    return this.mapToUserDetails(user, role);
  }

  async getUserByEmail(email: string): Promise<UserDetails> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Determine role by checking role tables
    let role: 'customer' | 'driver' | 'restaurant_owner' | undefined;

    const [customer, driver, owner] = await Promise.all([
      this.prisma.customer.findUnique({ where: { customer_id: user.user_id } }),
      this.prisma.driver.findUnique({ where: { driver_id: user.user_id } }),
      this.prisma.restaurant_owner.findUnique({ where: { owner_id: user.user_id } }),
    ]);

    if (customer) role = 'customer';
    else if (driver) role = 'driver';
    else if (owner) role = 'restaurant_owner';

    return this.mapToUserDetails(user, role);
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
  private mapToUserDetails(user: any, role?: 'customer' | 'driver' | 'restaurant_owner'): UserDetails {
    const nameParts = user.name.split(' ');
    const firstName = nameParts[0] || '';
    const lastName = nameParts.slice(1).join(' ') || '';

    return {
      userId: user.user_id,
      email: user.email || '',
      passwordHash: user.password_hash,
      firstName,
      lastName,
      role,
      phone: user.phone,
    };
  }

  /**
   * Helper: Generate user ID
   */
  private async generateUserId(): Promise<string> {
    const result = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
      SELECT 'USR' + FORMAT(NEXT VALUE FOR dbo.USR_SQ, 'D13') AS new_id
    `;
    return result[0].new_id;
  }
}
