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
import { FileService } from '../file/file.service';
import { Express } from 'express';

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

  async create(createSitterDto: CreateSitterDto, userId: number, file?: Express.Multer.File): Promise<Sitter> {
    // 1. Fetch the existing User entity.
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // --- LOGIC CHANGE: Check for existing profile instead of throwing error ---
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
        // Update the User's phone_number property
        user.phone_number = createSitterDto.phoneNumber;
        await this.userRepository.save(user);
        
        // Remove from DTO to avoid TypeORM error
        delete createSitterDto.phoneNumber; 
    }

    if (sitter) {
        // === UPDATE EXISTING PROFILE ===
        // The user is already a sitter, so we update their existing profile.
        
        // If a new file was uploaded, update the URL
        if (idDocumentUrl) {
            sitter.idDocumentUrl = idDocumentUrl;
        }

        // Apply new data from the form (Step 4 data)
        Object.assign(sitter, createSitterDto);
        
        await this.sitterRepository.save(sitter);
    } else {
        // === CREATE NEW PROFILE ===
        // No profile found, create a brand new one.
        sitter = this.sitterRepository.create({
          ...createSitterDto,
          userId,
          idDocumentUrl: idDocumentUrl,
        });

        await this.sitterRepository.save(sitter);
    }

    // 4. Ensure role is 'sitter' (just in case)
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
}
