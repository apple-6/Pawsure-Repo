import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from '../user/user.entity';
import { Booking } from '../booking/booking.entity';
import { Review } from '../review/review.entity';

@Entity('sitters')
export class Sitter {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({ type: 'text', nullable: true })
  experience: string;

  @Column({ type: 'text', nullable: true })
  photo_gallery: string;

  @Column({ type: 'double precision', default: 0 })
  rating: number;

  @Column({ type: 'int', default: 0 })
  reviews_count: number;

  @Column({ type: 'simple-array', nullable: true })
  available_dates: string[];

  // Additional fields for setupProfile
  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ type: 'varchar', nullable: true })
  phoneNumber: string;

  @Column({ type: 'varchar', nullable: true })
  houseType: string;

  @Column({ type: 'boolean', default: false })
  hasGarden: boolean;

  @Column({ type: 'boolean', default: false })
  hasOtherPets: boolean;

  @Column({ type: 'varchar', nullable: true })
  idDocumentUrl: string;

  @Column({ type: 'double precision', nullable: true })
  ratePerNight: number;

  @Column({ unique: true, nullable: true })
  userId: number;

  @OneToOne(() => User, (user) => user.sitterProfile, { nullable: true })
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => Booking, (booking) => booking.sitter)
  bookings: Booking[];

  @OneToMany(() => Review, (review) => review.sitter)
  reviews: Review[];

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}