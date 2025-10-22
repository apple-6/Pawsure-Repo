import { User } from 'src/user/user.entity';
export declare class Notification {
    id: number;
    message: string;
    type: string;
    status: string;
    created_at: Date;
    updated_at: Date;
    user: User;
}
