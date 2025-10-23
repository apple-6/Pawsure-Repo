import { Booking } from 'src/booking/booking.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { User } from 'src/user/user.entity';
export declare class Review {
    id: number;
    rating: number;
    comment: string;
    created_at: Date;
    updated_at: Date;
    booking: Booking;
    sitter: Sitter;
    owner: User;
}
