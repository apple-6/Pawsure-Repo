import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Post } from './posts.entity';

@Entity('post_media')
export class PostMedia {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  media_url: string;

  @Column({ default: 'image' })
  media_type: string;

  @ManyToOne(() => Post, (post) => post.post_media, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })  // ADD THIS LINE
  post: Post;
}