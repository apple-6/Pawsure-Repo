import { Pet } from 'src/pet/pet.entity';
export declare class HealthRecord {
    id: number;
    record_type: string;
    record_date: string;
    description: string;
    clinic: string;
    nextDueDate: string;
    created_at: Date;
    updated_at: Date;
    pet: Pet;
}
