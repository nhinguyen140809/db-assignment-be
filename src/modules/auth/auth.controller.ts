import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginRequestDto, RegisterRequestDto, AuthResponseDto } from './dtos';
import { plainToInstance } from 'class-transformer';
import { Public } from '../../common';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User registered successfully', type: AuthResponseDto })
  @ApiResponse({ status: 400, description: 'Bad request - user already exists or invalid data' })
  async register(@Body() registerRequestDto: RegisterRequestDto): Promise<AuthResponseDto> {
    const authResponse = await this.authService.register(registerRequestDto);
    return plainToInstance(AuthResponseDto, authResponse, {
      excludeExtraneousValues: true,
    });
  }

  @Public()
  @Post('login')
  @ApiOperation({ summary: 'Login with email and password' })
  @ApiResponse({ status: 200, description: 'Login successful', type: AuthResponseDto })
  @ApiResponse({ status: 401, description: 'Unauthorized - invalid credentials' })
  async login(@Body() loginRequestDto: LoginRequestDto): Promise<AuthResponseDto> {
    const authResponse = await this.authService.login(loginRequestDto);
    return plainToInstance(AuthResponseDto, authResponse, {
      excludeExtraneousValues: true,
    });
  }
}
