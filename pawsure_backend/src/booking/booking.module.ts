import { Module } from '@nestjs/common';
import { BookingService } from './booking.service';
import { BookingController } from './booking.controller'; 
import { TypeOrmModule } from '@nestjs/typeorm';
import { Booking } from './booking.entity';
import { Sitter } from '../sitter/sitter.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Booking, Sitter])],
  controllers: [BookingController],
  providers: [BookingService],
  exports: [BookingService]
})
export class BookingModule {}