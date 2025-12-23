import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { ActivityLog } from './activity-log.entity';
import { Pet } from '../pet/pet.entity';
import { CreateActivityLogDto } from './dto/create-activity-log.dto';
import { UpdateActivityLogDto } from './dto/update-activity-log.dto';

@Injectable()
export class ActivityLogService {
  constructor(
    @InjectRepository(ActivityLog)
    private activityLogRepository: Repository<ActivityLog>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
  ) {}

  async create(petId: number, dto: CreateActivityLogDto, userId: number): Promise<ActivityLog> {
    // Verify pet ownership
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

    const activity = this.activityLogRepository.create({
      ...dto,
      pet: { id: petId },
      activity_date: new Date(dto.activity_date),
    });

    return this.activityLogRepository.save(activity);
  }

  async findAllByPet(
    petId: number,
    userId: number,
    filters?: { type?: string; startDate?: string; endDate?: string },
  ): Promise<ActivityLog[]> {
    // Verify ownership
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
    });
  }

  async getStats(petId: number, userId: number, period: 'day' | 'week' | 'month') {
    // Verify ownership
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

    switch (period) {
      case 'day':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        break;
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
    }

    const activities = await this.activityLogRepository.find({
      where: {
        pet: { id: petId },
        activity_date: Between(startDate, now),
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
      activity.activity_date = new Date(dto.activity_date);
    }

    return this.activityLogRepository.save(activity);
  }

  async remove(id: number, userId: number): Promise<void> {
    const activity = await this.findOne(id, userId);
    await this.activityLogRepository.remove(activity);
  }
}
