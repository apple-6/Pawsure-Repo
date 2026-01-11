// pawsure_backend/src/events/entities/event.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, UpdateDateColumn } from 'typeorm';
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

  // ✅ CRITICAL FIX: Use 'timestamp with time zone'
  @Column({ type: 'timestamptz' })
  dateTime: Date;

  @Column({ type: 'enum', enum: EventType })
  eventType: EventType;

  @Column({ type: 'enum', enum: EventStatus, default: EventStatus.UPCOMING })
  status: EventStatus;

  @Column({ nullable: true })
  location?: string;

  @Column({ type: 'text', nullable: true })
  notes?: string;

  // ✅ NEW: Array of pet IDs for multi-pet events
  @Column('int', { array: true, default: () => 'ARRAY[]::integer[]' })
  pet_ids: number[];

  // ✅ KEEP: Single petId for backward compatibility (deprecated)
  @Column({ nullable: true })
  petId?: number;

  @ManyToOne(() => Pet, { onDelete: 'CASCADE' })
  pet?: Pet;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}