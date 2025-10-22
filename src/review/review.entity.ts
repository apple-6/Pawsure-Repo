// src/review/review.entity.ts
import { Booking } from 'src/booking/booking.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { User } from 'src/user/user.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne
} from 'typeorm';

@Entity('reviews')
export class Review {
  @PrimaryGeneratedColumn() // 'INT review_id PK'
  id: number;

  @Column({ type: 'float' }) // 'FLOAT rating'
  rating: number;

  @Column({ type: 'text', nullable: true }) // 'TEXT comment'
  comment: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => Booking, (booking) => booking.reviews) // 'INT booking_id FK'
  booking: Booking;

  @ManyToOne(() => Sitter, (sitter) => sitter.reviews) // 'INT sitter_id FK'
  sitter: Sitter;

  @ManyToOne(() => User, (user) => user.reviews) // 'INT owner_id FK'
  owner: User;
}
