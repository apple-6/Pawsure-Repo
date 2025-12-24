import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
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
  post: Post;
}