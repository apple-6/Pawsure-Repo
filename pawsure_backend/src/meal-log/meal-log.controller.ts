import { Controller, Post, Get, Body, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { MealLogService } from './meal-log.service';
import { CreateMealLogDto } from './dto/create-meal-log.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('pets/:petId/meals')
@UseGuards(JwtAuthGuard)
export class MealLogController {
  constructor(private readonly mealLogService: MealLogService) {}

  @Post()
  async create(
    @Param('petId', ParseIntPipe) petId: number,
    @Body() dto: CreateMealLogDto,
  ) {
    return this.mealLogService.create(petId, dto);
  }

  @Get('today')
  async getTodayMeals(@Param('petId', ParseIntPipe) petId: number) {
    return this.mealLogService.getTodayMeals(petId);
  }
}
