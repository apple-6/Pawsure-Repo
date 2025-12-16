import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
  BadRequestException, // Added for date validation
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

// Helper function to generate required date/day arrays
// Note: You might want to move this to a utility file in a real app.
// Days are returned in the PostgreSQL standard format (e.g., 'Mon', 'Tue').
function generateSearchRangeArrays(startDateStr: string, endDateStr: string): { searchDates: string[], searchDays: string[] } {
    const start = new Date(startDateStr);
    const end = new Date(endDateStr);

    if (isNaN(start.getTime()) || isNaN(end.getTime()) || start > end) {
        throw new BadRequestException('Invalid date range provided.');
    }

    const searchDates: string[] = [];
    const searchDaysSet: Set<string> = new Set();
    
    // Day names for PostgreSQL array (e.g., 'Sun', 'Mon', 'Tue', ...)
    // Note: JS getDay() returns 0 for Sunday, 1 for Monday, etc.
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    let currentDate = new Date(start);
    
    while (currentDate <= end) {
        // Format date as 'YYYY-MM-DD' for comparison with DATE[] column
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

    async create(createSitterDto: CreateSitterDto, userId: number, file?: Express.Multer.File): Promise<Sitter> {
        // ... (rest of your create method remains unchanged) ...
        // Note: Make sure the DTO for createSitterDto contains the new 'unavailable_dates' and 'unavailable_days' fields if you allow initial setting.
    
        // 1. Fetch the existing User entity.
        const user = await this.userRepository.findOne({ where: { id: userId } });
        
        if (!user) {
          throw new NotFoundException('User not found');
        }

        // Check if user already has a sitter profile
        if (user.role === 'sitter') {
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
            // Assuming unavailable_dates/days are handled by TypeORM's default [] if not set, or are in the DTO
        });

        await this.sitterRepository.save(sitter);

        
        user.role = 'sitter';
        // Save the updated User record (which holds all Sitter data).
        await this.userRepository.save(user);

        // 3. Update the role and save the complete, single entity (record in the 'users' table).
        user.role = 'sitter';
        await this.userRepository.save(user);

        // 4. Fetch the record using the SitterRepository to return the correct Sitter type.
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
        // ... (rest of your findAll method remains unchanged) ...
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
        // ... (rest of your findOne method remains unchanged) ...
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
        // ... (rest of your findByUserId method remains unchanged) ...
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
        // ... (rest of your update method remains unchanged) ...
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
        // ... (rest of your remove method remains unchanged) ...
        const sitter = await this.findOne(id);

        // Check if the user owns this sitter profile
        if (sitter.userId !== userId) {
            throw new ForbiddenException('You can only delete your own sitter profile');
        }

        // We rely on TypeORM's configuration (soft-delete behavior) when removing the entity.
        await this.sitterRepository.remove(sitter);
    }

    async updateRating(id: number): Promise<Sitter> {
        // ... (rest of your updateRating method remains unchanged) ...
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
    
    /**
     * Searches for available sitters within a continuous date range (X to Y).
     * @param startDate The start date of the booking (X, e.g., '2025-12-10').
     * @param endDate The end date of the booking (Y, e.g., '2025-12-12').
     * @returns A list of Sitter profiles available for the entire range.
     */
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
                searchDates: searchDates, // e.g., ['2025-12-10', '2025-12-11', ...]
            })
            
            // --- Unavailability Check 2: Recurring Days ---
            // Filter OUT sitters where their unavailable_days array OVERLAPS (&&) the requested searchDays array.
            .andWhere(`NOT ("sitter"."unavailable_days" && :searchDays)`, {
                searchDays: searchDays, // e.g., ['Mon', 'Tue', 'Wed', ...]
            })
            
            // --- General Filtering ---
            .andWhere('sitter.deleted_at IS NULL')
            
            .orderBy('sitter.rating', 'DESC')
            .getMany();
    }
}
