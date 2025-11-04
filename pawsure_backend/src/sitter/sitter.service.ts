import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Sitter } from './sitter.entity';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { SitterSetupDto } from './dto/sitter-setup.dto';
import { UserService } from '../user/user.service';

@Injectable()
export class SitterService {
  constructor(
    @InjectRepository(Sitter)
    private readonly sitterRepository: Repository<Sitter>,
    private readonly userService: UserService,
  ) {}

  /**
   * Creates or updates a Sitter's setup profile.
   */
  async setupProfile(userId: number, setupDto: SitterSetupDto) {
    // 1. Find the user
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // 2. Find their existing sitter profile, or create a new one
    let sitterProfile = await this.sitterRepository.findOne({
      where: { userId },
    });

    if (!sitterProfile) {
      sitterProfile = this.sitterRepository.create({ userId });
    }

    // 3. Map all data from the DTO to the entity
    sitterProfile.address = setupDto.address;
    sitterProfile.phoneNumber = setupDto.phoneNumber;
    sitterProfile.houseType = setupDto.houseType;
    sitterProfile.hasGarden = setupDto.hasGarden;
    sitterProfile.hasOtherPets = setupDto.hasOtherPets;
    sitterProfile.idDocumentUrl = setupDto.idDocumentUrl;
    sitterProfile.bio = setupDto.bio;
    sitterProfile.ratePerNight = setupDto.ratePerNight;

    // 4. Save the sitter profile
    await this.sitterRepository.save(sitterProfile);

    // 5. Update the user's role to 'sitter'
    await this.userService.updateUserRole(user.id, 'sitter');

    return sitterProfile;
  }

  async create(createSitterDto: CreateSitterDto, userId: number): Promise<Sitter> {
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

    // Create sitter profile
    const sitter = this.sitterRepository.create({
      ...createSitterDto,
      userId,
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
      .orderBy('sitter.rating', 'DESC');

    if (minRating) {
      query.where('sitter.rating >= :minRating', { minRating });
    }

    return await query.getMany();
  }

  async findOne(id: number): Promise<Sitter> {
    const sitter = await this.sitterRepository.findOne({
      where: { id },
      relations: ['user', 'reviews', 'bookings'],
    });

    if (!sitter) {
      throw new NotFoundException(`Sitter with ID ${id} not found`);
    }

    return sitter;
  }

  async findByUserId(userId: number): Promise<Sitter | null> {
    return await this.sitterRepository.findOne({
      where: { userId },
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

    Object.assign(sitter, updateSitterDto);
    return await this.sitterRepository.save(sitter);
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