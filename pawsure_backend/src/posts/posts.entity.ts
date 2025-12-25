import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany } from 'typeorm';
import { User } from '../user/user.entity';
import { PostMedia } from './post-media.entity';
import { Comment } from '../comments/comments.entity'; // ✅ Import Comment Entity
import { Like } from '../likes/likes.entity';           // ✅ Import Like Entity

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  image_url: string;

  @Column({ default: 0 })
  likes_count: number;

  @Column({ default: false })
  is_urgent: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Link to User (Fixed property name to 'user' to match your error log)
  @ManyToOne(() => User, (user) => user.posts)
  user: User;

  @Column({ nullable: true })
  userId: number;

  @OneToMany(() => PostMedia, (media) => media.post)
  post_media: PostMedia[];

  // ✅ ADD THESE TWO RELATIONSHIPS TO FIX THE ERRORS:
  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  @OneToMany(() => Like, (like) => like.post)
  likes: Like[];
}