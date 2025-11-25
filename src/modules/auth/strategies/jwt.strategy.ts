import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthService } from '../auth.service';
import { JwtPayload } from '../interfaces';
import { GetUserResponseDto } from '../../users/dtos';
import { plainToInstance } from 'class-transformer';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET ?? 'secret-key',
    });
  }
  async validate(payload: JwtPayload): Promise<GetUserResponseDto> {
    const { userId } = payload;
    const user = await this.authService.validateUser(userId);
    return plainToInstance(GetUserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }
}
