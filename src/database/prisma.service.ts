import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient, Prisma } from '../../generated/prisma/client';

export { Prisma };

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit(): Promise<void> {
    await this.$connect();
    Logger.log('PrismaClient connected successfully');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
