import { User } from 'src/user/user.entity';
import { Post } from 'src/posts/posts.entity';
export declare class Comment {
    id: number;
    content: string;
    created_at: Date;
    updated_at: Date;
    post: Post;
    user: User;
}
