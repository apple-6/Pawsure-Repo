// src/payment/payment.entity.ts
import { Booking } from 'src/booking/booking.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToOne, JoinColumn
} from 'typeorm';

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn() // 'INT payment_id PK'
  id: number;

  @Column({ type: 'float' }) // 'FLOAT amount'
  amount: number;

  @Column({ type: 'date' }) // 'DATE payment_date'
  payment_date: string;

  @Column() // 'STRING status'
  status: string;

  @Column() // 'STRING payment_method'
  payment_method: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @OneToOne(() => Booking, (booking) => booking.payment) // 'INT booking_id FK'
  @JoinColumn() // This side holds the 'booking_id' foreign key
  booking: Booking;
}
