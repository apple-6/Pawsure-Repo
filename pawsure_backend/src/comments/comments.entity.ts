// src/comments/comments.entity.ts
import { User } from 'src/user/user.entity';
import { Post } from 'src/posts/posts.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne
} from 'typeorm';

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn() // 'INT comment_id PK'
  id: number;

  @Column({ type: 'text' }) // 'TEXT content'
  content: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => Post, (post) => post.comments) // 'INT post_id FK'
  post: Post;

  @ManyToOne(() => User, (user) => user.comments) // 'INT user_id FK'
  user: User;
}
