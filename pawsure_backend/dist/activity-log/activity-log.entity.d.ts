import { Pet } from 'src/pet/pet.entity';
export declare class ActivityLog {
    id: number;
    activity_type: string;
    duration: number;
    distance: number;
    timestamp: Date;
    created_at: Date;
    updated_at: Date;
    pet: Pet;
}
