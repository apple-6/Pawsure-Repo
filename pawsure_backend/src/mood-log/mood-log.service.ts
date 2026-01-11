import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { MoodLog } from './mood-log.entity';
import { CreateMoodLogDto } from './dto/create-mood-log.dto';
import { Pet } from '../pet/pet.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { MealLog } from '../meal-log/meal-log.entity';
import { PetService } from '../pet/pet.service';

@Injectable()
export class MoodLogService {
  constructor(
    @InjectRepository(MoodLog)
    private moodLogRepository: Repository<MoodLog>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
    @InjectRepository(ActivityLog)
    private activityLogRepository: Repository<ActivityLog>,
    @InjectRepository(MealLog)
    private mealLogRepository: Repository<MealLog>,
    @Inject(forwardRef(() => PetService))
    private petService: PetService,
  ) {}

  /**
   * Log a mood and update streak
   */
  async create(petId: number, dto: CreateMoodLogDto): Promise<{ moodLog: MoodLog; streak: number }> {
    // 1. Find the pet
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }

    // 2. Get today's date (without time)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 3. Check if mood already logged today (update instead of create)
    const existingLog = await this.moodLogRepository.findOne({
      where: {
        petId,
        log_date: today,
      },
    });

    let moodLog: MoodLog;
    if (existingLog) {
      // Update existing log
      existingLog.mood_score = dto.mood_score;
      if (dto.mood_label !== undefined) existingLog.mood_label = dto.mood_label;
      if (dto.notes !== undefined) existingLog.notes = dto.notes;
      moodLog = await this.moodLogRepository.save(existingLog);
    } else {
      // Create new log
      moodLog = this.moodLogRepository.create({
        ...dto,
        petId,
        log_date: today,
      });
      moodLog = await this.moodLogRepository.save(moodLog);
    }

    // 4. Calculate and update streak
    const streak = await this.petService.calculateAndUpdateStreak(petId);

    // 5. Update pet's mood_rating with latest score
    pet.mood_rating = dto.mood_score;
    await this.petRepository.save(pet);

    return { moodLog, streak };
  }

  /**
   * Get mood history for a pet
   */
  async getMoodHistory(petId: number, days: number = 30): Promise<MoodLog[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.moodLogRepository.find({
      where: {
        petId,
        log_date: MoreThanOrEqual(startDate),
      },
      order: { log_date: 'DESC' },
    });
  }

  /**
   * Get today's mood
   */
  async getTodayMood(petId: number): Promise<MoodLog | null> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.moodLogRepository.findOne({
      where: {
        petId,
        log_date: today,
      },
    });
  }

  /**
   * Get streak info for a pet
   */
  async getStreakInfo(petId: number): Promise<{
    currentStreak: number;
    longestStreak: number;
    totalDaysLogged: number;
    lastActivityDate: Date | null;
  }> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }

    return {
      currentStreak: pet.streak || 0,
      longestStreak: pet.streak || 0, 
      totalDaysLogged: 0, // Simplified for now
      lastActivityDate: pet.last_activity_date || null,
    };
  }
}

