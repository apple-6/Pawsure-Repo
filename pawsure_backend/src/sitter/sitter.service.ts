import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
  BadRequestException, // Kept from Version M for date validation
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Sitter } from './sitter.entity';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { User } from '../user/user.entity';
import { UserService } from '../user/user.service';
import { FileService } from '../file/file.service';    
import { UpdateAvailabilityDto } from './dto/update-availability.dto';
import { validate } from 'class-validator';
import { Express } from 'express';

// --- HELPER FUNCTION (From Version M) ---
// Generates arrays of specific dates and day names for the search query
function generateSearchRangeArrays(startDateStr: string, endDateStr: string): { searchDates: string[], searchDays: string[] } {
    const start = new Date(startDateStr);
    const end = new Date(endDateStr);

    if (isNaN(start.getTime()) || isNaN(end.getTime()) || start > end) {
        throw new BadRequestException('Invalid date range provided.');
    }

    const searchDates: string[] = [];
    const searchDaysSet: Set<string> = new Set();
    
    // Day names for PostgreSQL array (e.g., 'Sun', 'Mon', 'Tue', ...)
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    let currentDate = new Date(start);
    
    while (currentDate <= end) {
        // Format date as 'YYYY-MM-DD'
        const dateString = currentDate.toISOString().split('T')[0];
        searchDates.push(dateString);

        // Get the day of the week string
        const dayIndex = currentDate.getDay();
        const dayString = daysOfWeek[dayIndex];
        searchDaysSet.add(dayString);

        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }
    
    return { 
        searchDates: searchDates, 
        searchDays: Array.from(searchDaysSet) 
    };
}

@Injectable()
export class SitterService {
  constructor(
    @InjectRepository(Sitter)
    private readonly sitterRepository: Repository<Sitter>,
    private readonly userService: UserService,
    private readonly fileService: FileService,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  // --- CREATE METHOD (From Version S - The "Fixer") ---
  // This version checks if a profile actually exists and "Upserts" it.
  // It effectively heals the "Zombie User" bug.
  async create(createSitterDto: CreateSitterDto, userId: number, file?: Express.Multer.File): Promise<Sitter> {
    // 1. Fetch the existing User entity.
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check actual sitter table, NOT just the user role.
    let sitter = await this.sitterRepository.findOne({ where: { userId } });

    // 2. Handle ID Document File Upload
    let idDocumentUrl: string | undefined;
    if (file) {
        idDocumentUrl = await this.fileService.uploadPublicFile(
            file.buffer, 
            file.originalname, 
            'sitter-id-documents'
        );
        delete createSitterDto.idDocumentUrl; // Clean DTO
    }

    // 3. Handle User Data (Phone Number)
    if (createSitterDto.phoneNumber) {
        user.phone_number = createSitterDto.phoneNumber;
        await this.userRepository.save(user);
        delete createSitterDto.phoneNumber; 
    }

    if (sitter) {
        // === UPDATE EXISTING PROFILE ===
        // If the zombie profile exists (or partially exists), we update it.
        if (idDocumentUrl) {
            sitter.idDocumentUrl = idDocumentUrl;
        }
        Object.assign(sitter, createSitterDto);
        await this.sitterRepository.save(sitter);
    } else {
        // === CREATE NEW PROFILE ===
        // If it was missing (even if role was 'sitter'), we create it now.
        sitter = this.sitterRepository.create({
          ...createSitterDto,
          userId,
          idDocumentUrl: idDocumentUrl,
        });

        await this.sitterRepository.save(sitter);
    }

    // 4. Ensure role is 'sitter' (Fixes the role if it was missing)
    if (user.role !== 'sitter') {
        user.role = 'sitter';
        await this.userRepository.save(user);
    }

    // 5. Return the full profile
    const finalSitter = await this.sitterRepository.findOne({ 
        where: { userId },
        relations: ['user'] 
    });

    if (!finalSitter) {
        throw new NotFoundException('Failed to retrieve Sitter profile after creation');
    }

    return finalSitter;
  }

  async findAll(minRating?: number): Promise<Sitter[]> {
    const query = this.sitterRepository
      .createQueryBuilder('sitter')
      .leftJoinAndSelect('sitter.user', 'user')
      .where('sitter.deleted_at IS NULL')
      .orderBy('sitter.rating', 'DESC');

    if (minRating) {
      query.where('sitter.rating >= :minRating', { minRating });
    }

    return await query.getMany();
  }

  async findOne(id: number): Promise<Sitter> {
    const sitter = await this.sitterRepository.findOne({
      where: { id },
      withDeleted: false,
      relations: ['user', 'reviews', 'bookings'],
    });

    if (!sitter) {
      throw new NotFoundException(`Sitter with ID ${id} not found`);
    }

    return sitter;
  }

  async findByUserId(userId: number): Promise<Sitter | null> {
    return await this.sitterRepository.findOne({
      where: { userId, deleted_at: IsNull() },
      relations: ['user'],
    });
  }

  async update(
    id: number,
    updateSitterDto: UpdateSitterDto,
    userId: number,
  ): Promise<Sitter> {
    const sitter = await this.findOne(id);

    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only update your own sitter profile');
    }

    Object.assign(sitter, updateSitterDto);
    await this.sitterRepository.save(sitter);

    const freshSitter = await this.sitterRepository.findOne({
        where: { id },
        relations: ['user', 'reviews', 'bookings'],
    });

    if (!freshSitter) {
        throw new NotFoundException(`Sitter profile with ID ${id} not found after update.`);
    }

    return freshSitter;
  }

  async remove(id: number, userId: number): Promise<void> {
    const sitter = await this.findOne(id);

    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only delete your own sitter profile');
    }

    await this.sitterRepository.remove(sitter);
  }

  async updateRating(id: number): Promise<Sitter> {
    const sitter = await this.sitterRepository.findOne({
      where: { id },
      relations: ['reviews'],
    });

    if (!sitter) {
      throw new NotFoundException(`Sitter with ID ${id} not found`);
    }

    if (sitter.reviews && sitter.reviews.length > 0) {
      const totalRating = sitter.reviews.reduce(
        (sum, review) => sum + review.rating,
        0,
      );
      sitter.rating = totalRating / sitter.reviews.length;
      sitter.reviews_count = sitter.reviews.length;
    } else {
      sitter.rating = 0;
      sitter.reviews_count = 0;
    }

    return await this.sitterRepository.save(sitter);
  }

  // --- SEARCH METHOD (From Version M - The "Feature") ---
  // This uses the advanced range search and exclusion logic.
  async searchByAvailability(startDate: string, endDate: string): Promise<Sitter[]> {
    // 1. Generate the required arrays for the search range
    const { searchDates, searchDays } = generateSearchRangeArrays(startDate, endDate);

    // 2. Build the query to find sitters NOT overlapping with any unavailability
    return await this.sitterRepository
        .createQueryBuilder('sitter')
        .leftJoinAndSelect('sitter.user', 'user')
        
        // --- Unavailability Check 1: Specific Dates ---
        // Filter OUT sitters where their unavailable_dates array OVERLAPS (&&) the requested searchDates array.
        .andWhere(`NOT ("sitter"."unavailable_dates" && :searchDates)`, {
            searchDates: searchDates, 
        })
        
        // --- Unavailability Check 2: Recurring Days ---
        // Filter OUT sitters where their unavailable_days array OVERLAPS (&&) the requested searchDays array.
        .andWhere(`NOT ("sitter"."unavailable_days" && :searchDays)`, {
            searchDays: searchDays, 
        })
        
        // --- General Filtering ---
        .andWhere('sitter.deleted_at IS NULL')
        .orderBy('sitter.rating', 'DESC')
        .getMany();
  }

  async updateAvailability(
    userId: number,
    dto: UpdateAvailabilityDto,
  ): Promise<Sitter> {
    // 1. Find the sitter profile associated with this user
    const sitter = await this.findByUserId(userId);

    if (!sitter) {
      throw new NotFoundException('Sitter profile not found for this user.');
    }

    // 2. Update only the relevant fields
    if (dto.unavailable_dates !== undefined) {
      sitter.unavailable_dates = dto.unavailable_dates;
    }

    if (dto.unavailable_days !== undefined) {
      sitter.unavailable_days = dto.unavailable_days;
    }

    // 3. Save and return the updated profile
    return await this.sitterRepository.save(sitter);
  }
}