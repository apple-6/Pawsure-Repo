import { Injectable,NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking } from './booking.entity';

@Injectable()
export class BookingService {
  constructor(
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
  ) {}

  async create(bookingData: Partial<Booking>): Promise<Booking> {
    const booking = this.bookingRepository.create({
      ...bookingData,
      status: 'pending', 
    });
    return await this.bookingRepository.save(booking);
  }

  async updateStatus(id: number, status: 'accepted' | 'declined'): Promise<Booking> {
    const booking = await this.bookingRepository.findOne({ where: { id } });

    if (!booking) {
      throw new NotFoundException(`Booking with ID ${id} not found`);
    }

    booking.status = status;
    return await this.bookingRepository.save(booking);
  }

async findAllByUser(userId: any): Promise<Booking[]> {
  const uid = Number(userId);
  console.log(`🔍 Searching bookings for User ID: ${uid}`); 

  const results = await this.bookingRepository.find({
    where: { 
      owner: { id: uid } 
    },
    relations: ['pet', 'sitter', 'sitter.user'], 
    order: { created_at: 'DESC' }
  });

  console.log(`📊 Found ${results.length} bookings for user ${uid}`); // DEBUG LOG
  return results;
}

async findAllBySitter(sitterId: number): Promise<Booking[]> {
  console.log(`🔍 Searching bookings for Sitter ID: ${sitterId}`);

  const results = await this.bookingRepository.find({
    where: {
      sitter: { id: sitterId }
    },
    relations: ['pet', 'owner'],
    order: { created_at: 'DESC' }
  });

  console.log(`📊 Found ${results.length} bookings for sitter ${sitterId}`);
  return results;
}

async findAllBySitterUserId(userId: number): Promise<Booking[]> {
  console.log(`🔍 Searching bookings for Sitter with User ID: ${userId}`);

  const results = await this.bookingRepository.find({
    where: {
      sitter: { userId: userId }
    },
    relations: ['pet', 'owner'],
    order: { created_at: 'DESC' }
  });

  console.log(`📊 Found ${results.length} bookings for sitter user ${userId}`);
  return results;
}
}