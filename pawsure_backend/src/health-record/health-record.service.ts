//pawsure_backend\src\health-record\health-record.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HealthRecord } from './health-record.entity';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';
import { UpdateHealthRecordDto } from './dto/update-health-record.dto';
import { Pet } from 'src/pet/pet.entity';

@Injectable()
export class HealthRecordService {
  constructor(
    @InjectRepository(HealthRecord)
    private readonly healthRecordRepository: Repository<HealthRecord>,
    @InjectRepository(Pet)
    private readonly petRepository: Repository<Pet>,
  ) {}

  async create(petId: number, dto: CreateHealthRecordDto): Promise<HealthRecord> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }

    const record = this.healthRecordRepository.create({
      record_type: dto.record_type,
      record_date: new Date(dto.record_date).toISOString().slice(0, 10),
      description: dto.description ?? '',
      pet,
      clinic: dto.clinic,
      nextDueDate: dto.nextDueDate,
    });

    const savedRecord = await this.healthRecordRepository.save(record);
    // Reload without relations to avoid circular reference in response
    const reloadedRecord = await this.healthRecordRepository.findOne({
      where: { id: savedRecord.id },
    });
    if (!reloadedRecord) {
      throw new NotFoundException('Failed to reload saved health record');
    }
    return reloadedRecord;
  }

  async findAllForPet(petId: number): Promise<HealthRecord[]> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }
    return this.healthRecordRepository.find({
      where: { pet: { id: petId } },
      order: { record_date: 'DESC' },
      // Removed relations: ['pet'] to avoid circular reference serialization issues
    });
  }

  // ✅ NEW: Update health record
  async update(id: number, dto: UpdateHealthRecordDto): Promise<HealthRecord> {
    const record = await this.healthRecordRepository.findOne({ 
      where: { id },
      relations: ['pet']
    });
    
    if (!record) {
      throw new NotFoundException(`Health record with ID ${id} not found`);
    }

    // Update the fields
    if (dto.record_type !== undefined) {
      record.record_type = dto.record_type;
    }
    if (dto.record_date !== undefined) {
      record.record_date = new Date(dto.record_date).toISOString().slice(0, 10);
    }
    if (dto.description !== undefined) {
      record.description = dto.description;
    }
    if (dto.clinic !== undefined) {
      record.clinic = dto.clinic;
    }
    if (dto.nextDueDate !== undefined) {
      record.nextDueDate = dto.nextDueDate;
    }

    const savedRecord = await this.healthRecordRepository.save(record);
    
    // Reload without relations to avoid circular reference in response
    const reloadedRecord = await this.healthRecordRepository.findOne({
      where: { id: savedRecord.id },
    });
    
    if (!reloadedRecord) {
      throw new NotFoundException('Failed to reload updated health record');
    }
    
    return reloadedRecord;
  }

  // ✅ NEW: Delete health record
  async remove(id: number): Promise<void> {
    const record = await this.healthRecordRepository.findOne({ 
      where: { id } 
    });
    
    if (!record) {
      throw new NotFoundException(`Health record with ID ${id} not found`);
    }

    await this.healthRecordRepository.remove(record);
  }
}