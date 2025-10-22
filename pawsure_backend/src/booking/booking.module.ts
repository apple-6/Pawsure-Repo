import { Module } from '@nestjs/common';
import { BookingService } from './booking.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Booking } from './booking.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Booking])],
  providers: [BookingService],
  exports: [BookingService]
})
export class BookingModule {}