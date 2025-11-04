// src/sitter/sitter.entity.ts
import { Booking } from 'src/booking/booking.entity';
import { Review } from 'src/review/review.entity';
import { User } from 'src/user/user.entity';
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';

export enum SitterStatus {
  PENDING = 'pending', // Waiting for admin verification
  VERIFIED = 'verified',
  REJECTED = 'rejected',
}

@Entity('sitters')
export class Sitter {
  @PrimaryGeneratedColumn() // 'INT sitter_id PK'
  id: number;

  @Column({ nullable: true })
  address: string;

  @Column({ nullable: true })
  phoneNumber: string;

  @Column({ nullable: true })
  houseType: string;

  @Column({ nullable: true })
  hasGarden: boolean;

  @Column({ nullable: true })
  hasOtherPets: boolean;

  @Column({ nullable: true }) // URL of the uploaded ID
  idDocumentUrl: string;

  @Column({
    type: 'enum',
    enum: SitterStatus,
    default: SitterStatus.PENDING,
  })
  status: SitterStatus;

  // --- Step 4: Experience & Rates ---
  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true }) // NEW
  ratePerNight: number;

  @Column({ type: 'text', nullable: true }) // 'TEXT bio'
  bio: string;

  @Column({ type: 'text', nullable: true }) // 'TEXT experience'
  experience: string;

  @Column({ type: 'simple-array', nullable: true }) // 'STRING photo_gallery'
  photo_gallery: string[]; // simple-array is good for a list of URLs

  @Column({ type: 'float', default: 0 }) // 'FLOAT rating'
  rating: number;

  @Column({ default: 0 }) // 'INT reviews_count'
  reviews_count: number;

  @Column({ type: 'date', array: true, nullable: true }) // 'DATE[] available_dates'
  available_dates: string[];

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @OneToOne(() => User, (user) => user.sitterProfile) // 'INT user_id FK'
  @JoinColumn() // This side holds the 'user_id' foreign key
  user: User;

  @OneToMany(() => Booking, (booking) => booking.sitter)
  bookings: Booking[];

  @OneToMany(() => Review, (review) => review.sitter)
  reviews: Review[];
}
