import { Module } from '@nestjs/common';
import { PrismaModule } from './database/prisma.module';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { MenuModule } from './modules/menu/menu.module';

@Module({
  imports: [PrismaModule, UsersModule, AuthModule, MenuModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
