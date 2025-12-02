// pawsure_backend/src/events/entities/event.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { Pet } from '../../pet/pet.entity';

export enum EventType {
  HEALTH = 'health',
  SITTER = 'sitter',
  GROOMING = 'grooming',
  ACTIVITY = 'activity',
  OTHER = 'other',
}

export enum EventStatus {
  UPCOMING = 'upcoming',
  PENDING = 'pending',
  COMPLETED = 'completed',
  MISSED = 'missed',
}

@Entity('events')
export class Event {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column({ type: 'timestamp' })
  dateTime: Date;

  @Column({
    type: 'enum',
    enum: EventType,
    default: EventType.OTHER,
  })
  eventType: EventType;

  @Column({
    type: 'enum',
    enum: EventStatus,
    default: EventStatus.UPCOMING,
  })
  status: EventStatus;

  @Column({ type: 'text', nullable: true })
  location: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  // Ideally, use the relation to manage this, but having the ID column explicitly is helpful for APIs
  @Column()
  petId: number;

  @ManyToOne(() => Pet, (pet) => pet.events, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'petId' })
  pet: Pet;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}