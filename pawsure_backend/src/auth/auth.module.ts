// src/auth/auth.module.ts

import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller'; // <-- 1. IMPORTED
import { UserModule } from 'src/user/user.module';

@Module({
  imports: [UserModule], // So AuthService can use UserService
  controllers: [AuthController], // <-- 2. IS IT HERE?
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
