// src/posts/posts.entity.ts
import { User } from 'src/user/user.entity';
import { Comment } from 'src/comments/comments.entity';
import { Like } from 'src/likes/likes.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany
} from 'typeorm';

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn() // 'INT post_id PK'
  id: number;

  @Column({ type: 'text' }) // 'TEXT content'
  content: string;

  @Column({ nullable: true }) // 'STRING image_url'
  image_url: string;

  @Column({ default: 0 }) // 'INT likes_count'
  likes_count: number;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => User, (user) => user.posts) // 'INT user_id FK'
  user: User;

  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  @OneToMany(() => Like, (like) => like.post)
  likes: Like[];
}
