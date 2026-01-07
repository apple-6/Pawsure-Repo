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
    // ✅ CHECK FOR UNPAID BOOKINGS BEFORE ALLOWING NEW BOOKING
    const ownerId = bookingData.owner?.id;
    if (ownerId) {
      const unpaidBookings = await this.bookingRepository.find({
        where: {
          owner: { id: ownerId },
          status: 'completed', // Service completed but not paid
          is_paid: false,
        },
      });

      if (unpaidBookings.length > 0) {
        console.log(`❌ Owner ${ownerId} has ${unpaidBookings.length} unpaid booking(s)`);
        throw new Error(
          `You have ${unpaidBookings.length} unpaid booking(s). Please complete payment before booking a new sitter.`
        );
      }
    }

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

  // 🆕 Mark service as completed (sitter marks the job as done)
  async completeService(bookingId: number, userId: number): Promise<Booking> {
    console.log(`✅ Completing service for booking ${bookingId} by user ${userId}`);

    // Find booking with sitter relation
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['sitter', 'sitter.user'],
    });

    if (!booking) {
      throw new NotFoundException(`Booking ${bookingId} not found`);
    }

    // Verify that the logged-in user is the sitter for this booking
    if (booking.sitter.user.id !== userId) {
      throw new NotFoundException('You are not authorized to complete this booking');
    }

    // Update booking status
    booking.status = 'completed';
    booking.service_completed_at = new Date();

    return await this.bookingRepository.save(booking);
  }

  // 🆕 Process payment (owner pays after service is completed)
  async processPayment(bookingId: number, userId: number): Promise<Booking> {
    console.log(`💳 Processing payment for booking ${bookingId} by user ${userId}`);

    // Find booking with owner relation
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['owner', 'sitter'],
    });

    if (!booking) {
      throw new NotFoundException(`Booking ${bookingId} not found`);
    }

    // Verify that the logged-in user is the owner of this booking
    if (booking.owner.id !== userId) {
      throw new NotFoundException('You are not authorized to pay for this booking');
    }

    // Check if service is completed
    if (booking.status !== 'completed') {
      throw new NotFoundException('Service must be completed before payment can be processed');
    }

    // Check if already paid
    if (booking.is_paid) {
      throw new NotFoundException('This booking has already been paid');
    }

    // Process payment (in real app, integrate with payment gateway here)
    // For now, we just mark it as paid
    booking.is_paid = true;
    booking.paid_at = new Date();
    booking.status = 'paid';

    console.log(`✅ Payment processed successfully for booking ${bookingId}`);
    return await this.bookingRepository.save(booking);
  }
}