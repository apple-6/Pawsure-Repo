import { Injectable, NotFoundException, ForbiddenException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
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

  async create(petId: number, dto: CreateActivityLogDto, userId: number): Promise<ActivityLog> {
    const pet = await this.petRepository.findOne({ 
      where: { id: petId }, 
      relations: ['owner'] 
    });
    
    if (!pet) {
      throw new NotFoundException('Pet not found');
    }
    
    if (pet.owner.id !== userId) {
      throw new ForbiddenException('Not your pet');
    }

    // ✅ CRITICAL FIX: Parse as UTC explicitly
    const activityDateUtc = new Date(dto.activity_date);
    
    console.log('📥 Received activity_date:', dto.activity_date);
    console.log('📅 Parsed as Date:', activityDateUtc.toISOString());

    const activity = this.activityLogRepository.create({
      ...dto,
      pet: { id: petId },
      activity_date: activityDateUtc, // ✅ Store UTC
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

  async findAllByPet(
    petId: number,
    userId: number,
    filters?: { type?: string; startDate?: string; endDate?: string },
  ): Promise<ActivityLog[]> {
    const pet = await this.petRepository.findOne({ 
      where: { id: petId }, 
      relations: ['owner'] 
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
        new Date(filters.endDate)
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

  async getStats(petId: number, userId: number, period: 'day' | 'week' | 'month') {
    const pet = await this.petRepository.findOne({ 
      where: { id: petId }, 
      relations: ['owner'] 
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
      byType,
    };
  }

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

  async update(id: number, dto: UpdateActivityLogDto, userId: number): Promise<ActivityLog> {
    const activity = await this.findOne(id, userId);

    Object.assign(activity, dto);

    if (dto.activity_date) {
      // ✅ CRITICAL FIX: Parse as UTC
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

  async remove(id: number, userId: number): Promise<void> {
    const activity = await this.findOne(id, userId);
    const petId = activity.petId || (activity.pet ? activity.pet.id : 0);
    await this.activityLogRepository.remove(activity);
    await this.petService.calculateAndUpdateStreak(petId);
  }
}