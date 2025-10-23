import { User } from 'src/user/user.entity';
import { Comment } from 'src/comments/comments.entity';
import { Like } from 'src/likes/likes.entity';
export declare class Post {
    id: number;
    content: string;
    image_url: string;
    likes_count: number;
    created_at: Date;
    updated_at: Date;
    user: User;
    comments: Comment[];
    likes: Like[];
}
