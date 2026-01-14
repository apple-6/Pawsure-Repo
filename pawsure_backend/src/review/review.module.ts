import { Module } from '@nestjs/common';
import { ReviewService } from './review.service';
import { ReviewController } from './review.controller'; // ✅ Import Controller
import { TypeOrmModule } from '@nestjs/typeorm';
import { Review } from './review.entity';
import { Booking } from 'src/booking/booking.entity'; // ✅ Import Booking Entity

@Module({
  imports: [TypeOrmModule.forFeature([Review, Booking])], // ✅ Add Booking here
  controllers: [ReviewController], // ✅ Add Controller here
  providers: [ReviewService],
  exports: [ReviewService]
})
export class ReviewModule {}