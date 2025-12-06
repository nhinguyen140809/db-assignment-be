import { NestFactory, Reflector } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { GlobalJwtAuthGuard } from './modules/auth/guards/global-jwt-auth.guard';
import * as dotenv from 'dotenv';

dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip properties that don't have decorators
      forbidNonWhitelisted: true, // Throw error if non-whitelisted properties are found
      transform: true, // Transform payloads to DTO instances
    }),
  );

  // Global JWT Auth Guard - Secure by default
  const reflector = app.get(Reflector);
  app.useGlobalGuards(new GlobalJwtAuthGuard(reflector));

  // Enable CORS for frontend integration
  app.enableCors({
    origin: true, // Configure this for production
    credentials: true,
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
