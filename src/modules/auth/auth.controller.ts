import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginRequestDto, RegisterRequestDto, AuthResponseDto } from './dtos';
import { plainToInstance } from 'class-transformer';
import { Public } from '../../common';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  async register(@Body() registerRequestDto: RegisterRequestDto): Promise<AuthResponseDto> {
    const authResponse = await this.authService.register(registerRequestDto);
    return plainToInstance(AuthResponseDto, authResponse, {
      excludeExtraneousValues: true,
    });
  }

  @Public()
  @Post('login')
  async login(@Body() loginRequestDto: LoginRequestDto): Promise<AuthResponseDto> {
    const authResponse = await this.authService.login(loginRequestDto);
    return plainToInstance(AuthResponseDto, authResponse, {
      excludeExtraneousValues: true,
    });
  }
}
