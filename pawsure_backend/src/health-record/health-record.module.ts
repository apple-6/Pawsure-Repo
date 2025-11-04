import { Module } from '@nestjs/common';
import { HealthRecordService } from './health-record.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthRecord } from './health-record.entity';

@Module({
  imports: [TypeOrmModule.forFeature([HealthRecord])],
  providers: [HealthRecordService],
  exports: [HealthRecordService]
})
export class HealthRecordModule {}