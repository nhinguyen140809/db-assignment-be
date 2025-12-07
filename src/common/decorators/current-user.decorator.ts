import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';

/**
 * Custom decorator to extract the current user from the request object.
 * This decorator can be used in controllers to access the authenticated user.
 *
 * Usage:
 * @User() user: UserEntity
 */
export const User = createParamDecorator((_data: unknown, ctx: ExecutionContext) => {
  const request: Request = ctx.switchToHttp().getRequest();
  return request.user;
});

export const CurrentUser = User;
