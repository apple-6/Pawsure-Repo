import { Booking } from 'src/booking/booking.entity';
export declare class Payment {
    id: number;
    amount: number;
    payment_date: string;
    status: string;
    payment_method: string;
    created_at: Date;
    updated_at: Date;
    booking: Booking;
}
