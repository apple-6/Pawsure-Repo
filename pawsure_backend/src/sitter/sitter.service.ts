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
    // 2. Inject the User Repository
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(createSitterDto: CreateSitterDto, userId: number, file?: Express.Multer.File): Promise<Sitter> {
    // Check if user exists
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if user already has a sitter profile
    const existingSitter = await this.sitterRepository.findOne({
      where: { userId },
    });

    if (existingSitter) {
      throw new ConflictException('User already has a sitter profile');
    }

    // --- 1. Extract and Update User Data (Phone Number) ---
    // If phone number is provided, update the User entity
    if (createSitterDto.phoneNumber) {
        // Retrieve the full User entity from the database
        const userToUpdate = await this.userRepository.findOne({ where: { id: userId } });
        
        if (userToUpdate) {
            // Update the User's phone_number property
            userToUpdate.phone_number = createSitterDto.phoneNumber;
            // Save the updated User entity to the 'users' table
            await this.userRepository.save(userToUpdate); 
        }

        // CRITICAL: Remove the property from the DTO!
        // This prevents TypeORM from throwing an error when mapping to the Sitter entity.
        delete createSitterDto.phoneNumber; 
    }
    
    // NOTE: If you were handling a file upload that provides idDocumentUrl, 
    // the logic for the file upload/URL assignment would also go here.
    // --- 2. Handle ID Document File Upload ---
    let idDocumentUrl: string | undefined;
    if (file) {
        // Call the service to upload the file buffer and get the public URL (e.g., from S3)
        //idDocumentUrl = 'PLACEHOLDER_ID_DOCUMENT_URL_';
        idDocumentUrl = await this.fileService.uploadPublicFile(
            file.buffer, 
            file.originalname, 
            'sitter-id-documents' // Optional: path/folder
        );
        // Clean up the DTO (just in case)
        delete createSitterDto.idDocumentUrl; 
    }
    // Create sitter profile
    const sitter = this.sitterRepository.create({
      ...createSitterDto,
      userId,
      idDocumentUrl: idDocumentUrl,
    });

    const savedSitter = await this.sitterRepository.save(sitter);

    // Update user role to 'sitter'
    await this.userService.updateUserRole(userId, 'sitter');

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
    const sitter = await this.findOne(id);

    // Check if the user owns this sitter profile
    if (sitter.userId !== userId) {
      throw new ForbiddenException('You can only update your own sitter profile');
    }

    if (updateSitterDto.phoneNumber) {
        // Find the user entity directly
        const user = await this.userRepository.findOne({ where: { id: userId } });
        
        if (user) {
            user.phone_number = updateSitterDto.phoneNumber;
            // Save the updated user entity separately
            await this.userRepository.save(user); 
        }
        
        // CRITICAL: Remove the redundant phoneNumber field from the DTO
        // so it doesn't get assigned to the Sitter entity
        delete updateSitterDto.phoneNumber; 

    }

    Object.assign(sitter, updateSitterDto);
    await this.sitterRepository.save(sitter);

    // 3. Get a FRESH Sitter object to ensure the related 'user' data is up-to-date
    // The previous findOne call might have stale user data, so we explicitly find it again
    const freshSitter = await this.sitterRepository.findOne({
        where: { id },
        relations: ['user', 'reviews', 'bookings'],
    });

    // Add this null check:
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
