import { Injectable, NotFoundException, ForbiddenException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, In } from 'typeorm';
import { ActivityLog } from './activity-log.entity';
import { Pet } from '../pet/pet.entity';
import { CreateActivityLogDto } from './dto/create-activity-log.dto';
import { UpdateActivityLogDto } from './dto/update-activity-log.dto';
import { PetService } from '../pet/pet.service';

@Injectable()
export class ActivityLogService {
  constructor(
    @InjectRepository(ActivityLog)
    private activityLogRepository: Repository<ActivityLog>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
    @Inject(forwardRef(() => PetService))
    private petService: PetService,
  ) {}

  /**
   * ✅ NEW: Create activity for multiple pets at once
   * Creates one activity record per pet with identical data
   */
  async createForMultiplePets(
    petIds: number[],
    dto: CreateActivityLogDto,
    userId: number,
  ): Promise<ActivityLog[]> {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📥 Creating activity for multiple pets');
    console.log('   Pet IDs:', petIds);
    console.log('   Activity Type:', dto.activity_type);
    console.log('   User ID:', userId);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // STEP 1: Validate all pets exist
    const pets = await this.petRepository.find({
      where: { id: In(petIds) },
      relations: ['owner'],
    });

    if (pets.length !== petIds.length) {
      const foundIds = pets.map(p => p.id);
      const missingIds = petIds.filter(id => !foundIds.includes(id));
      throw new NotFoundException(
        `Pets not found: ${missingIds.join(', ')}`,
      );
    }

    // STEP 2: Validate user owns ALL selected pets
    const unauthorizedPets = pets.filter(pet => pet.owner.id !== userId);
    if (unauthorizedPets.length > 0) {
      const unauthorizedNames = unauthorizedPets.map(p => p.name).join(', ');
      throw new ForbiddenException(
        `You don't own these pets: ${unauthorizedNames}`,
      );
    }

    // STEP 3: Parse activity date as UTC
    const activityDateUtc = new Date(dto.activity_date);
    console.log('📅 Activity Date (UTC):', activityDateUtc.toISOString());

    // STEP 4: Create activity for each pet (parallel execution for performance)
    const activityPromises = petIds.map(async (petId) => {
      const activity = this.activityLogRepository.create({
        activity_type: dto.activity_type,
        title: dto.title,
        description: dto.description,
        duration_minutes: dto.duration_minutes,
        distance_km: dto.distance_km,
        calories_burned: dto.calories_burned,
        activity_date: activityDateUtc,
        route_data: dto.route_data,
        pet: { id: petId },
      });

      return this.activityLogRepository.save(activity);
    });

    const savedActivities = await Promise.all(activityPromises);

    console.log('✅ Successfully created activities:');
    savedActivities.forEach((activity, index) => {
      console.log(`   [${index + 1}] ID: ${activity.id}, Pet: ${petIds[index]}, Date: ${activity.activity_date.toISOString()}`);
    });
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return savedActivities;
  }

  /**
   * ✅ KEPT: Original single-pet creation (legacy support)
   * Used by legacy endpoint /activity-logs/pets/:petId
   */
  async create(petId: number, dto: CreateActivityLogDto, userId: number): Promise<ActivityLog> {
    const pet = await this.petRepository.findOne({
      where: { id: petId },
      relations: ['owner'],
    });

    if (!pet) {
      throw new NotFoundException('Pet not found');
    }

    if (pet.owner.id !== userId) {
      throw new ForbiddenException('Not your pet');
    }

    const activityDateUtc = new Date(dto.activity_date);

    console.log('📥 Received activity_date:', dto.activity_date);
    console.log('📅 Parsed as Date:', activityDateUtc.toISOString());

    const activity = this.activityLogRepository.create({
      activity_type: dto.activity_type,
      title: dto.title,
      description: dto.description,
      duration_minutes: dto.duration_minutes,
      distance_km: dto.distance_km,
      calories_burned: dto.calories_burned,
      activity_date: activityDateUtc,
      route_data: dto.route_data,
      pet: { id: petId },
    });

    const savedActivity = await this.activityLogRepository.save(activity);
    
    // Recalculate streak
    await this.petService.calculateAndUpdateStreak(petId);

    console.log('✅ Created activity:', {
      id: savedActivity.id,
      title: savedActivity.title,
      activity_date: savedActivity.activity_date.toISOString(),
    });
    
    return savedActivity;
  }

  /**
   * Get all activities for a specific pet with optional filters
   */
  async findAllByPet(
    petId: number,
    userId: number,
    filters?: { type?: string; startDate?: string; endDate?: string },
  ): Promise<ActivityLog[]> {
    const pet = await this.petRepository.findOne({
      where: { id: petId },
      relations: ['owner'],
    });

    if (!pet) {
      throw new NotFoundException('Pet not found');
    }

    if (pet.owner.id !== userId) {
      throw new ForbiddenException('Not your pet');
    }

    const query: any = { pet: { id: petId } };

    if (filters?.type) {
      query.activity_type = filters.type;
    }

    if (filters?.startDate && filters?.endDate) {
      query.activity_date = Between(
        new Date(filters.startDate),
        new Date(filters.endDate),
      );
    }

    return this.activityLogRepository.find({
      where: query,
      order: { activity_date: 'DESC' },
      select: [
        'id',
        'petId',
        'activity_type',
        'title',
        'description',
        'duration_minutes',
        'distance_km',
        'calories_burned',
        'activity_date',
        'route_data',
        'created_at',
        'updated_at',
      ],
    });
  }

  /**
   * Get activity statistics for a specific pet
   */
  async getStats(petId: number, userId: number, period: 'day' | 'week' | 'month') {
    const pet = await this.petRepository.findOne({
      where: { id: petId },
      relations: ['owner'],
    });

    if (!pet) {
      throw new NotFoundException('Pet not found');
    }

    if (pet.owner.id !== userId) {
      throw new ForbiddenException('Not your pet');
    }

    const now = new Date();
    let startDate: Date;
    let endDate: Date = now;

    switch (period) {
      case 'day':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
        endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
        break;
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    }

    console.log(`📊 Fetching stats for Pet ${petId}, Period: ${period}, Range: ${startDate.toISOString()} to ${endDate.toISOString()}`);

    const activities = await this.activityLogRepository.find({
      where: {
        petId: petId,
        activity_date: Between(startDate, endDate),
      },
    });

    const totalDuration = activities.reduce((sum, a) => sum + (a.duration_minutes || 0), 0);
    const totalDistance = activities.reduce((sum, a) => sum + (Number(a.distance_km) || 0), 0);
    const totalCalories = activities.reduce((sum, a) => sum + (a.calories_burned || 0), 0);

    const byType = activities.reduce((acc, a) => {
      acc[a.activity_type] = (acc[a.activity_type] || 0) + 1;
      return acc;
    }, {});

    return {
      period,
      totalActivities: activities.length,
      totalDuration,
      totalDistance,
      totalCalories,
      activityBreakdown: byType,
    };
  }

  /**
   * Get a single activity by ID
   */
  async findOne(id: number, userId: number): Promise<ActivityLog> {
    const activity = await this.activityLogRepository.findOne({
      where: { id },
      relations: ['pet', 'pet.owner'],
    });

    if (!activity) {
      throw new NotFoundException('Activity not found');
    }

    if (activity.pet.owner.id !== userId) {
      throw new ForbiddenException('Not your activity');
    }

    return activity;
  }

  /**
   * Update an activity
   */
  async update(id: number, dto: UpdateActivityLogDto, userId: number): Promise<ActivityLog> {
    const activity = await this.findOne(id, userId);

    // Update fields
    if (dto.activity_type !== undefined) activity.activity_type = dto.activity_type;
    if (dto.title !== undefined) activity.title = dto.title;
    if (dto.description !== undefined) activity.description = dto.description;
    if (dto.duration_minutes !== undefined) activity.duration_minutes = dto.duration_minutes;
    if (dto.distance_km !== undefined) activity.distance_km = dto.distance_km;
    if (dto.calories_burned !== undefined) activity.calories_burned = dto.calories_burned;
    if (dto.route_data !== undefined) activity.route_data = dto.route_data;

    if (dto.activity_date) {
      const activityDateUtc = new Date(dto.activity_date);

      console.log('📥 Update received activity_date:', dto.activity_date);
      console.log('📅 Parsed as Date:', activityDateUtc.toISOString());

      activity.activity_date = activityDateUtc;
    }

    const saved = await this.activityLogRepository.save(activity);
    
    // Recalculate streak
    await this.petService.calculateAndUpdateStreak(activity.petId || (activity.pet ? activity.pet.id : 0));

    console.log('✅ Updated activity:', {
      id: saved.id,
      activity_date: saved.activity_date.toISOString(),
    });

    return saved;
  }

  /**
   * Delete an activity
   */
  async remove(id: number, userId: number): Promise<void> {
    const activity = await this.findOne(id, userId);
    const petId = activity.petId || (activity.pet ? activity.pet.id : 0);
    await this.activityLogRepository.remove(activity);
    await this.petService.calculateAndUpdateStreak(petId);
  }
}