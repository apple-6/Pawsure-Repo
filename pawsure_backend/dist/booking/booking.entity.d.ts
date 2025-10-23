import { Payment } from 'src/payment/payment.entity';
import { Pet } from 'src/pet/pet.entity';
import { Review } from 'src/review/review.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { User } from 'src/user/user.entity';
export declare class Booking {
    id: number;
    start_date: string;
    end_date: string;
    status: string;
    total_amount: number;
    created_at: Date;
    updated_at: Date;
    owner: User;
    sitter: Sitter;
    pet: Pet;
    payment: Payment;
    reviews: Review[];
}
