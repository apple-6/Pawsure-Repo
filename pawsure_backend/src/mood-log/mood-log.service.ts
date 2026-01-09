import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { MoodLog } from './mood-log.entity';
import { CreateMoodLogDto } from './dto/create-mood-log.dto';
import { Pet } from '../pet/pet.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';

@Injectable()
export class MoodLogService {
  constructor(
    @InjectRepository(MoodLog)
    private moodLogRepository: Repository<MoodLog>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
    @InjectRepository(ActivityLog)
    private activityLogRepository: Repository<ActivityLog>,
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
    const streak = await this.calculateAndUpdateStreak(petId);

    // 5. Update pet's mood_rating with latest score
    pet.mood_rating = dto.mood_score;
    await this.petRepository.save(pet);

    return { moodLog, streak };
  }

  /**
   * Calculate streak based on consecutive days with ANY activity
   * Activities include: activity_logs (walks, runs) + mood_logs
   */
  async calculateAndUpdateStreak(petId: number): Promise<number> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) return 0;

    // Get unique dates with activity in the last 365 days
    const activeDates = await this.getActiveDates(petId, 365);
    
    if (activeDates.length === 0) {
      pet.streak = 0;
      pet.last_activity_date = undefined as any; // Clear the date
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
      pet.last_activity_date = undefined as any; // Clear the date
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
   * Get unique dates with any activity (mood logs + activity logs)
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

    // Combine and dedupe dates
    const dateSet = new Set<string>();
    
    moodLogs.forEach(row => {
      if (row.date) dateSet.add(row.date.toISOString().split('T')[0]);
    });
    
    activityLogs.forEach(row => {
      if (row.date) dateSet.add(row.date.toISOString().split('T')[0]);
    });

    // Convert to Date objects
    return Array.from(dateSet).map(dateStr => {
      const d = new Date(dateStr);
      d.setHours(0, 0, 0, 0);
      return d;
    });
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

    // Get all active dates for stats
    const activeDates = await this.getActiveDates(petId, 365);

    return {
      currentStreak: pet.streak || 0,
      longestStreak: pet.streak || 0, // Could track separately if needed
      totalDaysLogged: activeDates.length,
      lastActivityDate: pet.last_activity_date || null,
    };
  }
}

