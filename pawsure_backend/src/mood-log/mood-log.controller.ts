import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { MoodLogService } from './mood-log.service';
import { CreateMoodLogDto } from './dto/create-mood-log.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('pets/:petId/mood')
export class MoodLogController {
  constructor(private readonly moodLogService: MoodLogService) {}

  /**
   * POST /pets/:petId/mood
   * Log a mood for the pet
   */
  @Post()
  async logMood(
    @Param('petId', ParseIntPipe) petId: number,
    @Body() dto: CreateMoodLogDto,
  ) {
    const result = await this.moodLogService.create(petId, dto);
    return {
      success: true,
      moodLog: result.moodLog,
      streak: result.streak,
      message: `Mood logged successfully! 🎯 Current streak: ${result.streak} days`,
    };
  }

  /**
   * GET /pets/:petId/mood/history?days=30
   * Get mood history
   */
  @Get('history')
  async getMoodHistory(
    @Param('petId', ParseIntPipe) petId: number,
    @Query('days') days?: string,
  ) {
    const numDays = days ? parseInt(days, 10) : 30;
    const history = await this.moodLogService.getMoodHistory(petId, numDays);
    return {
      petId,
      days: numDays,
      count: history.length,
      history,
    };
  }

  /**
   * GET /pets/:petId/mood/today
   * Get today's mood (if logged)
   */
  @Get('today')
  async getTodayMood(@Param('petId', ParseIntPipe) petId: number) {
    const mood = await this.moodLogService.getTodayMood(petId);
    return {
      petId,
      logged: !!mood,
      mood: mood || null,
    };
  }

  /**
   * GET /pets/:petId/mood/streak
   * Get streak information
   */
  @Get('streak')
  async getStreakInfo(@Param('petId', ParseIntPipe) petId: number) {
    return this.moodLogService.getStreakInfo(petId);
  }
}

