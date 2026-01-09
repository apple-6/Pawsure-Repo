import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './review.entity';
import { CreateReviewDto } from './dto/create-review.dto';
import { Booking } from 'src/booking/booking.entity';

@Injectable()
export class ReviewService {
  constructor(
    @InjectRepository(Review)
    private reviewRepository: Repository<Review>,
    
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
  ) {}

  async create(createReviewDto: CreateReviewDto, ownerId: number): Promise<Review> {
    const { bookingId, rating, comment } = createReviewDto;

    // 1. Verify Booking exists
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['sitter', 'owner'], // ✅ Ensure 'owner' is loaded
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    // --- 🔍 DEBUG LOGS (Remove later) ---
    console.log('--- REVIEW DEBUG ---');
    console.log(`Booking ID: ${booking.id}`);
    console.log(`Logged-in User ID (from Token): ${ownerId}`);
    // Safe navigation in case owner is null
    console.log(`Booking Owner ID (from DB): ${booking.owner ? booking.owner.id : 'NULL'}`);
    // ------------------------------------

    // CHECK 1: Does the booking have an owner?
    if (!booking.owner) {
       throw new BadRequestException('This booking has no owner assigned in the database.');
    }

    // CHECK 2: Do the IDs match?
    if (booking.owner.id !== ownerId) {
      throw new BadRequestException(`You (ID: ${ownerId}) cannot review booking owned by User ID: ${booking.owner.id}`);
    }

    // 2. Create the Review
    const review = this.reviewRepository.create({
      rating,
      comment,
      booking, 
      sitter: booking.sitter, 
      owner: booking.owner,   
    });

    return await this.reviewRepository.save(review);
  }
}