// pawsure_backend/src/payment-method/payment-method.entity.ts
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../user/user.entity';

@Entity('payment_methods')
export class PaymentMethod {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 50 })
  cardType: string; // 'visa', 'mastercard', 'amex', etc.

  @Column({ length: 4 })
  lastFourDigits: string;

  @Column({ length: 100 })
  cardholderName: string;

  @Column({ length: 2 })
  expiryMonth: string;

  @Column({ length: 4 })
  expiryYear: string;

  @Column({ default: false })
  isDefault: boolean;

  @Column({ nullable: true })
  nickname: string; // Optional: "Personal Card", "Work Card", etc.

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}

