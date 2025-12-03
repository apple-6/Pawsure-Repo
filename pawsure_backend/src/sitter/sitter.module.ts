import { Module } from '@nestjs/common';
import { SitterService } from './sitter.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';
import { SitterController } from './sitter.controller';
import { UserModule } from 'src/user/user.module';
import { AuthModule } from 'src/auth/auth.module';
import { Booking } from '../booking/booking.entity';
import { User } from 'src/user/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Sitter,
      Booking,
      User,
    ]),
    UserModule,
    AuthModule,
  ],
  controllers: [SitterController],
  providers: [SitterService],
  exports: [SitterService],
})
export class SitterModule {}