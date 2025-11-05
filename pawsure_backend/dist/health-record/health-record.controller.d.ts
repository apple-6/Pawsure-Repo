import { HealthRecordService } from './health-record.service';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';
export declare class HealthRecordController {
    private readonly healthRecordService;
    constructor(healthRecordService: HealthRecordService);
    create(petId: number, createHealthRecordDto: CreateHealthRecordDto): Promise<import("./health-record.entity").HealthRecord>;
    findAllForPet(petId: number): Promise<import("./health-record.entity").HealthRecord[]>;
}
