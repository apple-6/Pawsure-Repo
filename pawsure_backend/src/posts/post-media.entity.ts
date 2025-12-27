import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { Post } from './posts.entity';

@Entity('post_media')
export class PostMedia {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  media_url: string;

  @Column({ default: 'image' })
  media_type: string;

  @Column({ nullable: true, name: 'post_id' })
  post_id: number;

  @ManyToOne(() => Post, (post) => post.post_media, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post: Post;

  @CreateDateColumn()
  created_at: Date;
}