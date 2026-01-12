import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MealLogService } from './meal-log.service';
import { MealLogController } from './meal-log.controller';
import { MealLog } from './meal-log.entity';
import { Pet } from '../pet/pet.entity';
import { MoodLogModule } from '../mood-log/mood-log.module';
import { PetModule } from '../pet/pet.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([MealLog, Pet]),
    MoodLogModule, // For streak calculation
    forwardRef(() => PetModule),
  ],
  controllers: [MealLogController],
  providers: [MealLogService],
  exports: [MealLogService],
})
export class MealLogModule {}
