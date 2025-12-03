import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Sitter } from './sitter.entity';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { User } from '../user/user.entity';
import { UserService } from '../user/user.service';

@Injectable()
export class SitterService {
  constructor(
    @InjectRepository(Sitter)
    private readonly sitterRepository: Repository<Sitter>,
    private readonly userService: UserService,

    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(createSitterDto: CreateSitterDto, userId: number): Promise<Sitter> {
    // 1. Fetch the existing User entity.
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if user already has a sitter profile
    if (user.role === 'sitter') {
      throw new ConflictException('User already has a sitter profile');
    }

    // 2. CORRECT LOGIC for Single Table Inheritance: Apply ALL DTO fields 
    // (user fields like phoneNumber + sitter fields like bio, rates) directly to the User object.
    Object.assign(user, createSitterDto);
    user.role = 'sitter';
    // Save the updated User record (which holds all Sitter data).
    await this.userRepository.save(user);

    // 3. Update the role and save the complete, single entity (record in the 'users' table).
    user.role = 'sitter';
    await this.userRepository.save(user);

    // 4. Fetch the record using the SitterRepository to return the correct Sitter type.
    const savedSitter = await this.sitterRepository.findOne({ 
        where: { userId },
        relations: ['user'] 
    });

    if (!savedSitter) {
        throw new NotFoundException('Failed to retrieve Sitter profile after creation');
    }

    return savedSitter;
  }

  async findAll(minRating?: number): Promise<Sitter[]> {
    const query = this.sitterRepository
      .createQueryBuilder('sitter')
      .leftJoinAndSelect('sitter.user', 'user')
      .where('sitter.deleted_at IS NULL')
      .orderBy('sitter.rating', 'DESC');

    if (minRating !== undefined && minRating !== null) {
      query.andWhere('sitter.rating >= :minRating', { minRating });
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
    // We fetch the Sitter entity (which contains both user and sitter data)
    const sitter = await this.findOne(id);

    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only update your own sitter profile');
    }

    // 5. CORRECT LOGIC for Single Table Inheritance: Apply ALL DTO properties directly to the Sitter entity.
    Object.assign(sitter, updateSitterDto);
    
    // We save the Sitter entity, updating the single shared record in the 'users' table.
    await this.sitterRepository.save(sitter);

    // Get a FRESH Sitter object to ensure all related data is up-to-date
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

    // Check if the user owns this sitter profile
    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only delete your own sitter profile');
    }

    // We rely on TypeORM's configuration (soft-delete behavior) when removing the entity.
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

  async searchByAvailability(date: string): Promise<Sitter[]> {
    if (!date || date.trim() === '') {
      // If no date provided, return all sitters
      return await this.findAll();
    }

    try {
      // Get all sitters first, then filter in memory
      // This is more reliable than complex PostgreSQL array queries
      const allSitters = await this.findAll();
      
      // Filter sitters that have the date in their available_dates array
      const filteredSitters = allSitters.filter((sitter) => {
        // Skip if no available_dates
        if (!sitter.available_dates || sitter.available_dates.length === 0) {
          return false;
        }
        
        // Check if the date string is in the array
        // TypeORM simple-array stores as string[], so we can use includes
        return sitter.available_dates.some((availableDate) => {
          // Normalize dates for comparison (remove time if present)
          const normalizedAvailable = availableDate.split('T')[0];
          const normalizedSearch = date.split('T')[0];
          return normalizedAvailable === normalizedSearch;
        });
      });
      
      // Sort by rating (already sorted from findAll, but ensure it)
      return filteredSitters.sort((a, b) => b.rating - a.rating);
    } catch (error) {
      console.error('Error in searchByAvailability:', error);
      console.error('Error details:', error.message || error);
      // If anything fails, return all sitters as fallback
      return await this.findAll();
    }
  }
}
