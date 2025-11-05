import { Booking } from 'src/booking/booking.entity';
import { Review } from 'src/review/review.entity';
import { User } from 'src/user/user.entity';
export declare enum SitterStatus {
    PENDING = "pending",
    VERIFIED = "verified",
    REJECTED = "rejected"
}
export declare class Sitter {
    id: number;
    address: string;
    phoneNumber: string;
    houseType: string;
    hasGarden: boolean;
    hasOtherPets: boolean;
    idDocumentUrl: string;
    status: SitterStatus;
    ratePerNight: number;
    bio: string;
    experience: string;
    photo_gallery: string[];
    rating: number;
    reviews_count: number;
    available_dates: string[];
    created_at: Date;
    updated_at: Date;
    user: User;
    bookings: Booking[];
    reviews: Review[];
}
