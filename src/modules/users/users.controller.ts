import { Controller, Get, Body, Patch, Param, Delete } from '@nestjs/common';
import { UsersService } from './users.service';
import { GetUserResponseDto, UpdateUserRequestDto } from './dtos';
import { plainToInstance } from 'class-transformer';
import { User } from 'src/common';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}
  @Get()
  async getUser(@User() user: Express.User): Promise<GetUserResponseDto> {
    const currentUser = await this.usersService.getUser(user.userId);
    return plainToInstance(GetUserResponseDto, currentUser, {
      excludeExtraneousValues: true,
    });
  }
}
