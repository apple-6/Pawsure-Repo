import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Pet } from './pet.entity';
import { CreatePetDto } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { MoodLog } from '../mood-log/mood-log.entity';
import { MealLog } from '../meal-log/meal-log.entity';

@Injectable()
export class PetService {
  constructor(
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
    @InjectRepository(ActivityLog)
    private activityLogRepository: Repository<ActivityLog>,
    @InjectRepository(MoodLog)
    private moodLogRepository: Repository<MoodLog>,
    @InjectRepository(MealLog)
    private mealLogRepository: Repository<MealLog>,
  ) {}

  /**
   * Calculate streak based on consecutive days with ANY activity
   * Activities include: activity_logs (walks, runs) + mood_logs + meal_logs
   */
  async calculateAndUpdateStreak(petId: number): Promise<number> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) return 0;

    // Get unique dates with activity in the last 365 days
    const activeDates = await this.getActiveDates(petId, 365);
    
    if (activeDates.length === 0) {
      pet.streak = 0;
      pet.last_activity_date = null as any;
      await this.petRepository.save(pet);
      return 0;
    }

    // Sort dates descending (most recent first)
    activeDates.sort((a, b) => b.getTime() - a.getTime());

    // Check if today or yesterday has activity (streak must be recent)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    const mostRecentDate = activeDates[0];
    const isStreakActive = 
      mostRecentDate.getTime() === today.getTime() || 
      mostRecentDate.getTime() === yesterday.getTime();

    if (!isStreakActive) {
      // Streak broken
      pet.streak = 0;
      pet.last_activity_date = null as any;
      await this.petRepository.save(pet);
      return 0;
    }

    // Count consecutive days
    let streak = 1;
    for (let i = 0; i < activeDates.length - 1; i++) {
      const current = activeDates[i];
      const next = activeDates[i + 1];
      
      const diffDays = Math.round((current.getTime() - next.getTime()) / (1000 * 60 * 60 * 24));
      
      if (diffDays === 1) {
        streak++;
      } else {
        break; // Gap found, streak ends
      }
    }

    // Update pet
    pet.streak = streak;
    pet.last_activity_date = mostRecentDate;
    await this.petRepository.save(pet);

    return streak;
  }

  /**
   * Get unique dates with any activity (mood logs + activity logs + meal logs)
   */
  private async getActiveDates(petId: number, days: number): Promise<Date[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    // Get mood log dates
    const moodLogs = await this.moodLogRepository
      .createQueryBuilder('mood')
      .select('DISTINCT DATE(mood.log_date)', 'date')
      .where('mood.petId = :petId', { petId })
      .andWhere('mood.log_date >= :startDate', { startDate })
      .getRawMany();

    // Get activity log dates
    const activityLogs = await this.activityLogRepository
      .createQueryBuilder('activity')
      .select('DISTINCT DATE(activity.activity_date)', 'date')
      .where('activity.petId = :petId', { petId })
      .andWhere('activity.activity_date >= :startDate', { startDate })
      .getRawMany();

    // Get meal log dates
    const mealLogs = await this.mealLogRepository
      .createQueryBuilder('meal')
      .select('DISTINCT DATE(meal.log_date)', 'date')
      .where('meal.petId = :petId', { petId })
      .andWhere('meal.log_date >= :startDate', { startDate })
      .getRawMany();

    // Combine and dedupe dates
    const dateSet = new Set<string>();
    
    moodLogs.forEach(row => {
      if (row.date) dateSet.add(new Date(row.date).toISOString().split('T')[0]);
    });
    
    activityLogs.forEach(row => {
      if (row.date) dateSet.add(new Date(row.date).toISOString().split('T')[0]);
    });

    mealLogs.forEach(row => {
      if (row.date) dateSet.add(new Date(row.date).toISOString().split('T')[0]);
    });

    // Convert to Date objects
    return Array.from(dateSet).map(dateStr => {
      const d = new Date(dateStr);
      d.setHours(0, 0, 0, 0);
      return d;
    });
  }

  async create(createPetDto: CreatePetDto): Promise<Pet> {
    const pet = this.petRepository.create(createPetDto);
    return await this.petRepository.save(pet);
  }

  async findAll(ownerId?: number): Promise<Pet[]> {
    if (ownerId) {
      return await this.petRepository.find({
        where: { ownerId },
        relations: ['owner'],
        order: { created_at: 'DESC' },
      });
    }
    return await this.petRepository.find({
      relations: ['owner'],
      order: { created_at: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Pet> {
    const pet = await this.petRepository.findOne({
      where: { id },
      relations: ['owner', 'activityLogs', 'healthRecords'],
    });

    if (!pet) {
      throw new NotFoundException(`Pet with ID ${id} not found`);
    }

    return pet;
  }

  async findByOwner(ownerId: number): Promise<Pet[]> {
    return await this.petRepository.find({
      where: { ownerId },
      relations: ['owner'],
      order: { created_at: 'DESC' },
    });
  }

  async update(
    id: number,
    updatePetDto: UpdatePetDto,
    userId: number,
  ): Promise<Pet> {
    const pet = await this.findOne(id);

    // Check if the user is the owner
    if (pet.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own pets');
    }

    Object.assign(pet, updatePetDto);
    return await this.petRepository.save(pet);
  }

  async remove(id: number, userId: number): Promise<void> {
    const pet = await this.findOne(id);

    // Check if the user is the owner
    if (pet.ownerId !== userId) {
      throw new ForbiddenException('You can only delete your own pets');
    }

    await this.petRepository.remove(pet);
  }

  async updateStreak(id: number, streak: number): Promise<Pet> {
    const pet = await this.findOne(id);
    pet.streak = streak;
    return await this.petRepository.save(pet);
  }

  async updateMoodRating(id: number, moodRating: number): Promise<Pet> {
    const pet = await this.findOne(id);
    pet.mood_rating = moodRating;
    return await this.petRepository.save(pet);
  }
}
