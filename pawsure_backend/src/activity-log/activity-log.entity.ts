// src/activity-log/activity-log.entity.ts
import { Pet } from 'src/pet/pet.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne
} from 'typeorm';

@Entity('activity_logs')
export class ActivityLog {
  @PrimaryGeneratedColumn() // 'INT log_id PK'
  id: number;

  @Column() // 'STRING activity_type'
  activity_type: string;

  @Column({ type: 'float', nullable: true }) // 'FLOAT duration'
  duration: number;

  @Column({ type: 'float', nullable: true }) // 'FLOAT distance'
  distance: number;

  @Column({ type: 'timestamp' }) // 'TIMESTAMP timestamp'
  timestamp: Date;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => Pet, (pet) => pet.activityLogs) // 'INT pet_id FK'
  pet: Pet;
}