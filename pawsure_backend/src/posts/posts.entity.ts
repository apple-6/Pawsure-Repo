import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../user/user.entity';
import { PostMedia } from './post-media.entity';
import { Comment } from '../comments/comments.entity'; // Import your Comment entity
import { Like } from '../likes/likes.entity';       // Import your Like entity


@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'text' })
  content: string;

  @Column({ name: 'userId' })
  userId: number;

  @Column({ default: false })
  is_urgent: boolean;

  @Column({ default: false })
  is_vacancy: boolean;

  @Column({ type: 'timestamp', nullable: true })
  start_date: Date;

  @Column({ type: 'timestamp', nullable: true })
  end_date: Date;

  @Column({ nullable: true })
  pet_id: string;

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => PostMedia, (media) => media.post)
  post_media: PostMedia[];

  // FIX: Add these two lines so Comments and Likes can "see" the post
  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  @OneToMany(() => Like, (like) => like.post)
  likes: Like[];
}