import { Module } from '@nestjs/common';
import { HealthRecordService } from './health-record.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthRecord } from './health-record.entity';
import { HealthRecordController } from './health-record.controller';
import { Pet } from 'src/pet/pet.entity';

@Module({
  imports: [TypeOrmModule.forFeature([HealthRecord, Pet])],
  controllers: [HealthRecordController],
  providers: [HealthRecordService],
  exports: [HealthRecordService]
})
export class HealthRecordModule {}