import { Injectable,NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking } from './booking.entity';
import { Sitter } from '../sitter/sitter.entity'; // 👈 IMPORT THIS

@Injectable()
export class BookingService {
  constructor(
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,

    @InjectRepository(Sitter)
    private sitterRepository: Repository<Sitter>,
) {}

  async create(bookingData: Partial<Booking>): Promise<Booking> {
    const booking = this.bookingRepository.create({
      ...bookingData,
      status: 'pending', 
    });
    return await this.bookingRepository.save(booking);
  }

  async updateStatus(id: number, status: 'accepted' | 'declined'| 'cancelled',): Promise<Booking> {
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
    console.log(`🔍 Step 1: Finding Sitter profile for User ID: ${userId}`);

    // 1. Find which Sitter ID belongs to this User
    const sitter = await this.sitterRepository.findOne({
      where: { user: { id: userId } }, // Assumes Sitter has a 'user' relation
    });

    if (!sitter) {
      console.warn(`⚠️ No Sitter profile found for User ID ${userId}. Returning empty list.`);
      return [];
    }

    console.log(`✅ Step 2: Found Sitter ID ${sitter.id}. Fetching bookings...`);

    // 2. Find bookings for that specific Sitter ID
    const bookings = await this.bookingRepository.find({
      where: { 
        sitter: { id: sitter.id } 
      },
      relations: ['pet', 'owner'], // Load Pet and Owner details for the UI
      order: { created_at: 'DESC' }
    });

    console.log(`📊 Found ${bookings.length} bookings for Sitter ID ${sitter.id}`);
    return bookings;
  }
}