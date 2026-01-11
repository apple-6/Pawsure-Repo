// pawsure_backend/src/pet/pet.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PetService } from './pet.service';
import { PetController } from './pet.controller';
import { Pet } from './pet.entity';
import { FileModule } from '../file/file.module';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { MoodLog } from '../mood-log/mood-log.entity';
import { MealLog } from '../meal-log/meal-log.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Pet, ActivityLog, MoodLog, MealLog]),
    FileModule, 
  ],
  controllers: [PetController],
  providers: [PetService],
  exports: [PetService],
})
export class PetModule {}