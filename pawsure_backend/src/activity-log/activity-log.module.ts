import { Module } from '@nestjs/common';
import { ActivityLogService } from './activity-log.service';
import { ActivityLogController } from './activity-log.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ActivityLog } from './activity-log.entity';
import { Pet } from '../pet/pet.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ActivityLog, Pet])],
  controllers: [ActivityLogController],
  providers: [ActivityLogService],
  exports: [ActivityLogService],
})
export class ActivityLogModule {}