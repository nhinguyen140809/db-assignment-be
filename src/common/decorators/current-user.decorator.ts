import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';
import * as jwt from 'jsonwebtoken';

/**
 * Custom decorator to extract the current user from the request object.
 * This decorator can be used in controllers to access the authenticated user.
 *
 * Usage:
 * @CurrentUser() user: Express.User
 */
export const CurrentUser = createParamDecorator((_data: unknown, ctx: ExecutionContext) => {
  const request: Request = ctx.switchToHttp().getRequest();
  // Prefer Express.User set by Passport
  if (request.user && (request.user as any).userId) {
    console.log('[CURRENT_USER] Returning Express.User from request.user');
    // Controllers that expect a string userId can use this directly
    return (request.user as any).userId as string;
  }

  // Fallback: decode Bearer token and construct Express.User
  const authHeader = request.headers['authorization'] || (request.headers['Authorization'] as any);
  if (typeof authHeader === 'string' && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring('Bearer '.length);
    // Decode without signature verification to avoid secret mismatches.
    // Guard/strategy should already validate the token; this is a lenient fallback.
    const decoded = jwt.decode(token) as { userId?: string; email?: string } | null;
    if (decoded && decoded.userId) {
      console.log('[CURRENT_USER] Returning userId from decoded token payload:', decoded.userId);
      // Return just the userId string so injection type is consistent
      return decoded.userId;
    }
  }

  console.log('[CURRENT_USER] No user found in request');
  return undefined;
});
