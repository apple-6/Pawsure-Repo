import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MoodLogService } from './mood-log.service';
import { MoodLogController } from './mood-log.controller';
import { MoodLog } from './mood-log.entity';
import { Pet } from '../pet/pet.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';

@Module({
  imports: [TypeOrmModule.forFeature([MoodLog, Pet, ActivityLog])],
  controllers: [MoodLogController],
  providers: [MoodLogService],
  exports: [MoodLogService],
})
export class MoodLogModule {}

