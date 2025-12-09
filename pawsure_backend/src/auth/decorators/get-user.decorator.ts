// src/auth/decorators/get-user.decorator.ts

import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { User } from 'src/user/user.entity';

export const GetUser = createParamDecorator(
  (_data: unknown, ctx: any): User => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
