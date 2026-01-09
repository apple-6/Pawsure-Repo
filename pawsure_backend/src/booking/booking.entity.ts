import { Payment } from 'src/payment/payment.entity';
import { Pet } from 'src/pet/pet.entity';
import { Review } from 'src/review/review.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { User } from 'src/user/user.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToOne, OneToMany,ManyToMany, JoinTable
} from 'typeorm';

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'date' })
  start_date: string;

  @Column({ type: 'date' })
  end_date: string;

  @Column()
  status: string; // pending, accepted, declined, in_progress, completed, paid, cancelled

  @Column({ type: 'float' })
  total_amount: number;
  
  @Column({ type: 'int', nullable: true })
  payment_method_id: number;

  @Column({ type: 'boolean', default: false })
  is_paid: boolean; // Track if owner has paid

  @Column({ type: 'timestamp', nullable: true })
  paid_at: Date; // When payment was made

  @Column({ type: 'timestamp', nullable: true })
  service_completed_at: Date; // When service was marked as completed

  @Column({ type: 'text', nullable: true })
  message: string;

  @Column()
  drop_off_time: string;

  @Column() 
  pick_up_time: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => User, (user) => user.bookings) // 'INT owner_id FK'
  owner: User;

  @ManyToOne(() => Sitter, (sitter) => sitter.bookings) // 'INT sitter_id FK'
  sitter: Sitter;

  // @ManyToOne(() => Pet, (pet) => pet.bookings) // 'INT pet_id FK'
  // pet: Pet;

  @ManyToMany(() => Pet, (pet) => pet.bookings)
  @JoinTable({ name: 'booking_pets' }) 
  pets: Pet[];

  @OneToOne(() => Payment, (payment) => payment.booking)
  payment: Payment;

  @OneToMany(() => Review, (review) => review.booking)
  reviews: Review[];
}
