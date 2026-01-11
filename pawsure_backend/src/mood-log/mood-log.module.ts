import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MoodLogService } from './mood-log.service';
import { MoodLogController } from './mood-log.controller';
import { MoodLog } from './mood-log.entity';
import { Pet } from '../pet/pet.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { MealLog } from '../meal-log/meal-log.entity';
import { PetModule } from '../pet/pet.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([MoodLog, Pet, ActivityLog, MealLog]),
    forwardRef(() => PetModule),
  ],
  controllers: [MoodLogController],
  providers: [MoodLogService],
  exports: [MoodLogService],
})
export class MoodLogModule {}

