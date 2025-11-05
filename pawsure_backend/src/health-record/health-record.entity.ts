// src/health-record/health-record.entity.ts
import { Pet } from 'src/pet/pet.entity';
import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne
} from 'typeorm';

@Entity('health_records')
export class HealthRecord {
  @PrimaryGeneratedColumn() // 'INT record_id PK'
  id: number;

  @Column() // STRING record_type
  record_type: string;

  @Column({ type: 'date' }) // DATE record_date
  record_date: string;

  @Column({ type: 'text' }) // TEXT description
  description: string;

  @Column({ nullable: true })
  clinic: string;

  @Column({ type: 'date', nullable: true })
  nextDueDate: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @ManyToOne(() => Pet, (pet) => pet.healthRecords) // 'INT pet_id FK'
  pet: Pet;
}
