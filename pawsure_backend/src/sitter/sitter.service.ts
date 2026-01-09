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

async findAll(minRating?: number): Promise<any[]> {
    const query = this.sitterRepository
      .createQueryBuilder('sitter')
      .leftJoinAndSelect('sitter.user', 'user')
      .leftJoin('sitter.reviews', 'review')
      // 1. Standardize aliases to snake_case to match raw results
      .addSelect('COUNT(review.id)', 'review_count')
      .addSelect('COALESCE(AVG(review.rating), 0)', 'avg_rating')
      .where('sitter.deleted_at IS NULL')
      .groupBy('sitter.id')
      .addGroupBy('user.id')
      // 2. Quote alias in orderBy for Postgres safety
      .orderBy('"avg_rating"', 'DESC');

    if (minRating) {
      query.having('COALESCE(AVG(review.rating), 0) >= :minRating', { minRating });
    }

    try {
      const { entities, raw } = await query.getRawAndEntities();

      return entities.map((sitter) => {
        const rawData = raw.find(r => r.sitter_id === sitter.id);
        
        // 🔴 FIX: Added 'as any' here to solve Error 2561
        return {
          ...sitter,
          // Map raw 'review_count' (string) to 'reviewCount' (number)
          reviewCount: rawData ? parseInt(rawData.review_count, 10) : 0,
          // Map raw 'avg_rating' (string) to 'rating' (number)
          rating: rawData ? parseFloat(rawData.avg_rating) : 0.0,
        } as any; 
      });
    } catch (error) {
      console.error("Error in findAll sitters:", error);
      throw new BadRequestException("Could not fetch sitters");
    }
  }
  
  async findOne(id: number): Promise<any> {
    const sitter = await this.sitterRepository.findOne({
      where: { id },
      withDeleted: false,
      relations: ['user', 'reviews', 'reviews.owner', 'bookings'],
    });

    if (!sitter) {
      throw new NotFoundException(`Sitter with ID ${id} not found`);
    }

    // 1. Calculate fresh stats from the reviews array
    const reviewCount = sitter.reviews ? sitter.reviews.length : 0;

    const totalRating = sitter.reviews
      ? sitter.reviews.reduce((sum, review) => sum + review.rating, 0)
      : 0;

    const avgRating = reviewCount > 0 ? totalRating / reviewCount : 0;
    return {
      ...sitter,
      rating: avgRating,  
      reviewCount: reviewCount, 
      reviews_count: reviewCount,
      
      reviews: sitter.reviews 
        ? sitter.reviews.sort((a, b) => b.created_at.getTime() - a.created_at.getTime()) 
        : []
    } as any;
  }

  async findByUserId(userId: number): Promise<Sitter | null> {
    return await this.sitterRepository.findOne({
      where: { userId, deleted_at: IsNull() },
      relations: ['user'],
    });
  }

  async update(
    id: number,
    updateSitterDto: any, // Use 'any' temporarily to allow 'name' property
    userId: number,
  ): Promise<Sitter> {
    const sitter = await this.findOne(id);

    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only update your own sitter profile');
    }

    // 1. 🟢 HANDLE NAME UPDATE (User Table)
    // If the payload has a 'name', we update the User table separately
    if (updateSitterDto.name) {
      await this.userRepository.update(userId, { name: updateSitterDto.name });
      
      // Remove 'name' from the DTO so we don't try to save it to the Sitter table
      // (This prevents "Column 'name' not found" errors)
      delete updateSitterDto.name;
    }

    // 2. HANDLE SITTER UPDATE
    Object.assign(sitter, updateSitterDto);
    await this.sitterRepository.save(sitter);

    // 3. RETURN FRESH DATA
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
  async searchByAvailability(startDate: string, endDate: string): Promise<any[]> {
    // 1. Generate the required arrays for the search range
    const { searchDates, searchDays } = generateSearchRangeArrays(startDate, endDate);

    // 2. Build the query to find sitters NOT overlapping with any unavailability
   // return await this.sitterRepository
   const query = this.sitterRepository
        .createQueryBuilder('sitter')
        .leftJoinAndSelect('sitter.user', 'user')
        .leftJoin('sitter.reviews', 'review')
        .addSelect('COUNT(review.id)', 'reviewCountRaw')
        .addSelect('COALESCE(AVG(review.rating), 0)', 'averageRatingRaw')
        
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
        .groupBy('sitter.id')
        .addGroupBy('user.id')
        .orderBy('averageRatingRaw', 'DESC');
try {
      const { entities, raw } = await query.getRawAndEntities();

      return entities.map((sitter) => {
        const rawData = raw.find(r => r.sitter_id === sitter.id);
        
        return {
          ...sitter,
          reviewCount: rawData ? parseInt(rawData.reviewCountRaw, 10) : 0, 
  rating: rawData ? parseFloat(rawData.averageRatingRaw) : 0.0,
        } as any;
      });
    } catch (error) {
      console.error("Error in searchByAvailability:", error);
      throw new BadRequestException("Search failed.");
    }
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