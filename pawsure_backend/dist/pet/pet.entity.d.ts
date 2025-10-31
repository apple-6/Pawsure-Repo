import { ActivityLog } from 'src/activity-log/activity-log.entity';
import { Booking } from 'src/booking/booking.entity';
import { HealthRecord } from 'src/health-record/health-record.entity';
import { User } from 'src/user/user.entity';
export declare class Pet {
    id: number;
    name: string;
    photoUrl: string;
    species: string;
    breed: string;
    dob: string;
    weight: number;
    allergies: string;
    vaccination_dates: string[];
    last_vet_visit: string;
    mood_rating: number;
    streak: number;
    created_at: Date;
    updated_at: Date;
    ownerId: number;
    owner: User;
    bookings: Booking[];
    activityLogs: ActivityLog[];
    healthRecords: HealthRecord[];
}
