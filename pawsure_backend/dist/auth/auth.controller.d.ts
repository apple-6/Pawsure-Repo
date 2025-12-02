import { AuthService } from './auth.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(registerUserDto: RegisterUserDto): Promise<{
        result: {
            id: number;
            name: string;
            email: string;
            phone_number: string;
            role: string;
            profile_picture: string;
            created_at: Date;
            updated_at: Date;
            pets: import("../pet/pet.entity").Pet[];
            sitterProfile: import("../sitter/sitter.entity").Sitter;
            bookings: import("../booking/booking.entity").Booking[];
            reviews: import("../review/review.entity").Review[];
            notifications: import("../notification/notification.entity").Notification[];
            posts: import("../posts/posts.entity").Post[];
            comments: import("../comments/comments.entity").Comment[];
            likes: import("../likes/likes.entity").Like[];
        };
        access_token: string;
    }>;
    login(loginUserDto: LoginUserDto): Promise<{
        access_token: string;
    }>;
    getProfile(req: any): {
        id: any;
        name: any;
        email: any;
        role: any;
        phone_number: any;
        profile_picture: any;
    };
}
