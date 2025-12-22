import { Controller, Post, Body, UseGuards, Request, Patch, Param,ParseIntPipe, Get } from '@nestjs/common';
import { BookingService } from './booking.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { User } from '../user/user.entity';
import { Sitter } from '../sitter/sitter.entity';
import { Pet } from '../pet/pet.entity';

@Controller('bookings')
export class BookingController {
  constructor(private readonly bookingService: BookingService) {}
@Get()
@UseGuards(JwtAuthGuard) 
async findAll(@Request() req) {
 
  return this.bookingService.findAllByUser(req.user.id); 
}

@Post()
@UseGuards(JwtAuthGuard)
async create(@Body() createBookingDto: CreateBookingDto, @Request() req) {
  return this.bookingService.create({
    start_date: createBookingDto.start_date,
    end_date: createBookingDto.end_date,
    total_amount: createBookingDto.total_amount,
    drop_off_time: createBookingDto.drop_off_time,
    pick_up_time: createBookingDto.pick_up_time,
    message: createBookingDto.message, // Ensure this is mapped here
    status: 'pending',
    owner: { id: req.user.id } as User,
    sitter: { id: createBookingDto.sitterId } as Sitter,
    pet: { id: createBookingDto.petId } as Pet,
  });
}

@Patch(':id/status')
  @UseGuards(JwtAuthGuard)
  async updateBookingStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: 'accepted' | 'declined',
  ) {
    return this.bookingService.updateStatus(id, status);
  }
}