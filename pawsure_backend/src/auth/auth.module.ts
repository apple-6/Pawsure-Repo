import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { UserModule } from '../user/user.module';
import { JwtSignOptions } from '@nestjs/jwt'; // Import the specific type if needed, but casting often works

@Module({
  imports: [
    UserModule,
    PassportModule,
    // Asynchronous registration of JwtModule to read config values
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'fallback-secret-key-12345',
        signOptions: {
          // RESOLUTION: Cast the string to the correct type (string | number)
          expiresIn: (configService.get<string>('JWT_EXPIRATION') || '1d') as JwtSignOptions['expiresIn'], 
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}