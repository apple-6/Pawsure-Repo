import { Repository } from 'typeorm';
import { HealthRecord } from './health-record.entity';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';
import { UpdateHealthRecordDto } from './dto/update-health-record.dto';
import { Pet } from 'src/pet/pet.entity';
export declare class HealthRecordService {
    private readonly healthRecordRepository;
    private readonly petRepository;
    constructor(healthRecordRepository: Repository<HealthRecord>, petRepository: Repository<Pet>);
    create(petId: number, dto: CreateHealthRecordDto): Promise<HealthRecord>;
    findAllForPet(petId: number): Promise<HealthRecord[]>;
    update(id: number, dto: UpdateHealthRecordDto): Promise<HealthRecord>;
    remove(id: number): Promise<void>;
}
