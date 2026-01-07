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
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'date' })
  start_date: string;

  @Column({ type: 'date' })
  end_date: string;

  @Column()
  status: string;

  @Column({ type: 'float' })
  total_amount: number;
  
  @Column({ type: 'int', nullable: true })
  payment_method_id: number;

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

  @ManyToOne(() => Pet, (pet) => pet.bookings) // 'INT pet_id FK'
  pet: Pet;

  @OneToOne(() => Payment, (payment) => payment.booking)
  payment: Payment;

  @OneToMany(() => Review, (review) => review.booking)
  reviews: Review[];
}
