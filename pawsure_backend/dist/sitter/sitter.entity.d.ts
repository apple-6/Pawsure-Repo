import { User } from '../user/user.entity';
import { Booking } from '../booking/booking.entity';
import { Review } from '../review/review.entity';
export declare enum SitterStatus {
    PENDING = "pending",
    APPROVED = "approved",
    REJECTED = "rejected"
}
export declare class Sitter {
    id: number;
    bio: string;
    experience: string;
    photo_gallery: string;
    rating: number;
    reviews_count: number;
    available_dates: string[];
    address: string;
    houseType: string;
    hasGarden: boolean;
    hasOtherPets: boolean;
    idDocumentUrl: string;
    ratePerNight: number;
    status: SitterStatus;
    userId: number;
    user: User;
    bookings: Booking[];
    reviews: Review[];
    created_at: Date;
    updated_at: Date;
    deleted_at: Date;
}
