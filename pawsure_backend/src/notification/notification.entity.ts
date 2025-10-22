// src/notification/notification.entity.ts
import { User } from 'src/user/user.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne
} from 'typeorm';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn() // 'INT notification_id PK'
  id: number;

  @Column({ type: 'text' }) // 'TEXT message'
  message: string;

  @Column() // 'STRING type'
  type: string;

  @Column({ default: 'unread' }) // 'STRING status'
  status: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => User, (user) => user.notifications) // 'INT user_id FK'
  user: User;
}
