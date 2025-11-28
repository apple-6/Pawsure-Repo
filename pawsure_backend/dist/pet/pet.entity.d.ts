import { User } from '../user/user.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { HealthRecord } from '../health-record/health-record.entity';
import { Booking } from '../booking/booking.entity';
export declare class Pet {
    id: number;
    name: string;
    species: string;
    breed: string;
    dob: Date;
    weight: number;
    allergies: string;
    vaccination_dates: string[];
    last_vet_visit: Date;
    mood_rating: number;
    streak: number;
    photoUrl: string;
    ownerId: number;
    owner: User;
    activityLogs: ActivityLog[];
    healthRecords: HealthRecord[];
    bookings: Booking[];
    created_at: Date;
    updated_at: Date;
}
