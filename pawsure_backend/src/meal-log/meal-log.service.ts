import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MealLog } from './meal-log.entity';
import { CreateMealLogDto } from './dto/create-meal-log.dto';
import { Pet } from '../pet/pet.entity';
import { PetService } from '../pet/pet.service';

@Injectable()
export class MealLogService {
  constructor(
    @InjectRepository(MealLog)
    private mealLogRepository: Repository<MealLog>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
    @Inject(forwardRef(() => PetService))
    private petService: PetService, 
  ) {}

  async create(petId: number, dto: CreateMealLogDto): Promise<{ mealLog: MealLog; streak: number }> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if this type of meal was already logged today
    let mealLog = await this.mealLogRepository.findOne({
      where: {
        petId,
        log_date: today,
        meal_type: dto.meal_type,
      },
    });

    if (!mealLog) {
      mealLog = this.mealLogRepository.create({
        petId,
        log_date: today,
        meal_type: dto.meal_type,
      });
      mealLog = await this.mealLogRepository.save(mealLog);
    }

    // Recalculate streak
    const streak = await this.petService.calculateAndUpdateStreak(petId);

    return { mealLog, streak };
  }

  async getTodayMeals(petId: number): Promise<MealLog[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.mealLogRepository.find({
      where: {
        petId,
        log_date: today,
      },
    });
  }
}
