import { UserService } from 'src/user/user.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { JwtService } from '@nestjs/jwt';
export declare class AuthService {
    private readonly userService;
    private readonly jwtService;
    constructor(userService: UserService, jwtService: JwtService);
    register(registerUserDto: RegisterUserDto): Promise<{
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
    }>;
    login(loginUserDto: LoginUserDto): Promise<{
        access_token: string;
    }>;
}
