import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinTable,
  JoinColumn,
} from 'typeorm';
import { User } from '../user/user.entity';
import { PostMedia } from './post-media.entity';
import { Comment } from '../comments/comments.entity';
import { Like } from '../likes/likes.entity';
import { Pet } from '../pet/pet.entity'; // Make sure this path is correct

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

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => PostMedia, (media) => media.post)
  post_media: PostMedia[];

  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  @OneToMany(() => Like, (like) => like.post)
  likes: Like[];

  // UPDATED: Many-to-Many relationship for multiple pets
  @ManyToMany(() => Pet)
  @JoinTable({
    name: 'post_pets', // This creates the junction table in Supabase
    joinColumn: { name: 'post_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'pet_id', referencedColumnName: 'id' }
  })
  pets: Pet[];

  // post.entity.ts
  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  rate_per_night: number | null;
}