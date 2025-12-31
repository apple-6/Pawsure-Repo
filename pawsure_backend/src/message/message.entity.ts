// src/chat/message.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../user/user.entity';

@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  text: string;

  // The "Room" ID usually acts as the booking ID or a unique string like "user1-user2"
  @Column()
  room: string; 

  @ManyToOne(() => User)
  sender: User;

  @CreateDateColumn()
  created_at: Date;
}