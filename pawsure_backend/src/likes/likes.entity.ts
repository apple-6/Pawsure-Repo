// src/likes/likes.entity.ts
import { User } from 'src/user/user.entity';
import { Post } from 'src/posts/posts.entity';
import {
  Entity, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne
} from 'typeorm';

@Entity('likes')
export class Like {
  @PrimaryGeneratedColumn() // 'INT like_id PK'
  id: number;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  // --- Relationships ---
  @ManyToOne(() => Post, (post) => post.likes) // 'INT post_id FK'
  post: Post;

  @ManyToOne(() => User, (user) => user.likes) // 'INT user_id FK'
  user: User;
}
