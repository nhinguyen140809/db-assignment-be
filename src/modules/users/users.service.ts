import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UserDetails, UpdateUserDetails, CreateUserDetails } from './interfaces/users.interface';
import * as bcrypt from 'bcrypt';
import { CreatePaymentMethodDto } from './dtos';

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

    //   if (!user) {
    //     throw new NotFoundException('User not found');
    //   }

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

  /**
   * Payment methods
   */

  async getPaymentMethodsForUser(userId: string) {
    const customer = await this.prisma.customer.findUnique({
      where: { customer_id: userId },
    });

    if (!customer) {
      throw new BadRequestException('Only customers have payment methods');
    }

    const methods = await this.prisma.payment_method.findMany({
      where: { customer_id: userId },
      orderBy: { payment_id: 'asc' },
      include: {
        cash: true,
        e_wallet: true,
        bank_card: true,
      },
    });

    // Infer type and surface provider/bank fields for the frontend.
    return methods.map(pm => {
      let type: 'CASH' | 'E_WALLET' | 'BANK_CARD' = 'CASH';
      let provider: string | undefined;
      let wallet_number: string | undefined;
      let bank_name: string | undefined;
      let card_number: string | undefined;
      let expiry_date: string | undefined;

      if (pm.e_wallet) {
        type = 'E_WALLET';
        provider = pm.e_wallet.provider;
        wallet_number = pm.e_wallet.wallet_number;
      } else if (pm.bank_card) {
        type = 'BANK_CARD';
        bank_name = pm.bank_card.bank_name;
        card_number = pm.bank_card.card_number;
        expiry_date = pm.bank_card.expiry_date?.toISOString();
      }

      return {
        payment_id: pm.payment_id,
        customer_id: pm.customer_id,
        type,
        provider,
        wallet_number,
        bank_name,
        card_number,
        expiry_date,
        created_at: new Date(),
      };
    });
  }

  async createPaymentMethodForUser(userId: string, dto: CreatePaymentMethodDto) {
    const customer = await this.prisma.customer.findUnique({
      where: { customer_id: userId },
    });

    if (!customer) {
      throw new BadRequestException('Only customers can create payment methods');
    }

    const result = await this.prisma.$queryRaw<Array<{ new_id: string }>>`
      SELECT 'PAY' + FORMAT(NEXT VALUE FOR dbo.PAY_SQ, 'D13') AS new_id
    `;
    const paymentId = result[0].new_id;

    // Create base payment_method row with only valid columns for this table.
    await this.prisma.payment_method.create({
      data: {
        payment_id: paymentId,
        customer_id: userId,
      },
    });

    // Create type-specific detail record without changing Prisma definitions.
    if (dto.type === 'CASH') {
      await this.prisma.cash.create({
        data: {
          cash_id: paymentId,
        },
      });
    }

    // For E_WALLET and BANK_CARD we assume separate tables already wired in Prisma
    // and simply call them via `any` without touching schema definitions.
    if (dto.type === 'E_WALLET') {
      await (this.prisma as any).e_wallet.create({
        data: {
          e_wallet_id: paymentId,
          provider: (dto as any).provider,
          wallet_number: (dto as any).wallet_number,
        },
      });
    }

    if (dto.type === 'BANK_CARD') {
      await (this.prisma as any).bank_card.create({
        data: {
          bank_card_id: paymentId,
          bank_name: (dto as any).bank_name,
          card_number: (dto as any).card_number,
          expiry_date: (dto as any).expiry_date,
        },
      });
    }

    return {
      payment_id: paymentId,
      customer_id: userId,
      type: dto.type,
      created_at: new Date(),
    };
  }

  async deletePaymentMethodForUser(userId: string, paymentId: string) {
    const method = await this.prisma.payment_method.findUnique({
      where: { payment_id: paymentId },
    });

    if (!method || method.customer_id !== userId) {
      throw new NotFoundException('Payment method not found or does not belong to you');
    }

    await this.prisma.payment_method.delete({
      where: { payment_id: paymentId },
    });

    return {
      success: true,
      message: 'Payment method deleted successfully',
    };
  }
}
