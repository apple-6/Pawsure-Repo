import { Booking } from 'src/booking/booking.entity';
import { Notification } from 'src/notification/notification.entity';
import { Pet } from 'src/pet/pet.entity';
import { Review } from 'src/review/review.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { Post } from 'src/posts/posts.entity';
import { Comment } from 'src/comments/comments.entity';
import { Like } from 'src/likes/likes.entity';
export declare class User {
    id: number;
    name: string;
    email: string;
    passwordHash: string;
    role: string;
    profile_picture: string;
    created_at: Date;
    updated_at: Date;
    pets: Pet[];
    sitterProfile: Sitter;
    bookings: Booking[];
    reviews: Review[];
    notifications: Notification[];
    posts: Post[];
    comments: Comment[];
    likes: Like[];
}
