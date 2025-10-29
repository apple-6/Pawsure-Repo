import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HealthRecord } from './health-record.entity';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';
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
      record_type: dto.recordType,
      record_date: new Date(dto.date).toISOString().slice(0, 10),
      description: dto.notes ?? '',
      pet,
    });

    return this.healthRecordRepository.save(record);
  }

  async findAllForPet(petId: number): Promise<HealthRecord[]> {
    const pet = await this.petRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found`);
    }
    return this.healthRecordRepository.find({
      where: { pet: { id: petId } },
      order: { record_date: 'DESC' },
      relations: ['pet'],
    });
  }
}
