import { Controller, Get, Body, Patch, Param, Delete } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { GetUserResponseDto, UpdateUserRequestDto } from './dtos';
import { plainToInstance } from 'class-transformer';
import { User } from 'src/common';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved', type: GetUserResponseDto })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUser(@User() user: Express.User): Promise<GetUserResponseDto> {
    const currentUser = await this.usersService.getUser(user.userId);
    return plainToInstance(GetUserResponseDto, currentUser, {
      excludeExtraneousValues: true,
    });
  }

  @Patch()
  async updateUser(@User() user: Express.User, @Body() updateUserRequestDto: UpdateUserRequestDto): Promise<void> {
    return await this.usersService.updateUser(user.userId, updateUserRequestDto);
  }

  @Delete()
  async deleteUser(@User() user: Express.User): Promise<void> {
    return await this.usersService.deleteUser(user.userId);
  }
}
