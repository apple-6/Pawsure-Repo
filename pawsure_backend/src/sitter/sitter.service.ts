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
import { Booking } from '../booking/booking.entity';
import { SearchSitterDto } from 'src/sitter/dto/sitter-search.dto';

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
    return await this.sitterRepository
      .createQueryBuilder('sitter')
      .leftJoinAndSelect('sitter.user', 'user')
      .where(':date = ANY(sitter.available_dates)', { date })
      .orderBy('sitter.rating', 'DESC')
      .getMany();
  }

  async searchSitters(searchDto: SearchSitterDto): Promise<Sitter[]> {
    const { location, startDate, endDate } = searchDto;

    const qb = this.sitterRepository.createQueryBuilder('sitter');

    // 1. Filter by Location
    if (location) {
      qb.andWhere('sitter.address ILIKE :location', {
        location: `%${location}%`,
      });
    }

    // 2. Filter by Date Availability
    // We only apply this filter if BOTH startDate and endDate are provided
    if (startDate && endDate) {
      // This subquery finds sitters who are *UNAVAILABLE*.
      // We look for any booking that overlaps with the requested date range.
      // An overlap occurs if:
      // (booking.start_date <= endDate) AND (booking.end_date >= startDate)
      
      qb.andWhere((subQuery) => {
        const sub = subQuery
          .subQuery()
          .select('booking.id')
          .from(Booking, 'booking')
          .where('booking.sitterId = sitter.id')
          // IMPORTANT: Only check against confirmed bookings!
          // Adjust 'confirmed' if your status enum is different.
          .andWhere("booking.status = 'confirmed'") 
          .andWhere(
            '(booking.start_date <= :endDate AND booking.end_date >= :startDate)',
            { startDate, endDate },
          )
          .getQuery();
        
        // The "NOT EXISTS" clause keeps sitters who have NO overlapping bookings.
        return `NOT EXISTS (${sub})`;
      });
    }

    // Ensure we only get active sitters (not deleted)
    qb.andWhere('sitter.deleted_at IS NULL');

    // Optional: Include relations you might want to show, e.g., user details
    qb.leftJoinAndSelect('sitter.user', 'user');

    return qb.getMany();
  }
}
