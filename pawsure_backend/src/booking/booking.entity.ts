// src/booking/booking.entity.ts
import { Payment } from 'src/payment/payment.entity';
import { Pet } from 'src/pet/pet.entity';
import { Review } from 'src/review/review.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { User } from 'src/user/user.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToOne, OneToMany
} from 'typeorm';

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn() // 'INT booking_id PK'
  id: number;

  @Column({ type: 'date' }) // 'DATE start_date'
  start_date: string;

  @Column({ type: 'date' }) // 'DATE end_date'
  end_date: string;

  @Column() // 'STRING status'
  status: string;

  @Column({ type: 'float' }) // 'FLOAT total_amount'
  total_amount: number;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => User, (user) => user.bookings) // 'INT owner_id FK'
  owner: User;

  @ManyToOne(() => Sitter, (sitter) => sitter.bookings) // 'INT sitter_id FK'
  sitter: Sitter;

  @ManyToOne(() => Pet, (pet) => pet.bookings) // 'INT pet_id FK'
  pet: Pet;

  @OneToOne(() => Payment, (payment) => payment.booking)
  payment: Payment;

  @OneToMany(() => Review, (review) => review.booking)
  reviews: Review[];
}
