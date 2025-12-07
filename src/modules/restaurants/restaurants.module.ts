import { Module } from '@nestjs/common';
import { RestaurantController } from './restaurants.controller';
import { RestaurantService } from './restaurants.service';
import { PrismaModule } from '../../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [RestaurantController],
  providers: [RestaurantService],
  exports: [RestaurantService],
})
export class RestaurantModule {}
