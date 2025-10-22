import { User } from 'src/user/user.entity';
import { Post } from 'src/posts/posts.entity';
export declare class Like {
    id: number;
    created_at: Date;
    post: Post;
    user: User;
}
