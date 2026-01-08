import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Pet } from '../pet/pet.entity';

@Entity('mood_logs')
export class MoodLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  mood_score: number; // 1-10 scale (3=sad, 5=neutral, 8=happy)

  @Column({ nullable: true })
  mood_label: string; // 'sad', 'neutral', 'happy', 'excited', 'anxious', etc.

  @Column({ type: 'text', nullable: true })
  notes: string; // Optional notes about the mood

  @Column({ type: 'date' })
  log_date: Date; // Date of the mood log (for streak calculation)

  @CreateDateColumn()
  created_at: Date;

  // --- Relationships ---
  @Column({ name: 'pet_id' })
  petId: number;

  @ManyToOne(() => Pet, (pet) => pet.moodLogs, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pet_id' })
  pet: Pet;
}

