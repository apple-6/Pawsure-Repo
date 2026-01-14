import { Controller, Post, Body, UseGuards, Request, BadRequestException } from '@nestjs/common';
import { ReviewService } from './review.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('reviews')
export class ReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  async create(@Body() createReviewDto: CreateReviewDto, @Request() req) {
    // 🔍 DEBUG LOG: See what is actually inside req.user
    console.log('--- AUTH DEBUG ---');
    console.log('User object from Token:', req.user); 

    // Handle different naming conventions (id vs userId vs sub)
    const userId = req.user.id || req.user.userId || req.user.sub;

    if (!userId) {
        throw new BadRequestException('Could not determine User ID from token.');
    }

    return this.reviewService.create(createReviewDto, userId);
  }
}