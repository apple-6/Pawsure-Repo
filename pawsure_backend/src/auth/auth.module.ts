// src/auth/auth.module.ts

import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from 'src/user/user.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    UserModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),

    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'), // Reads from .env
        signOptions: {
          expiresIn: '1d', // Token will expire in 1 day
        },
      }),
    }),
  ], // So AuthService can use UserService
  controllers: [AuthController], // <-- 2. IS IT HERE?
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
