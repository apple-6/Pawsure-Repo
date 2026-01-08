import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';
import { Pet } from '../pet/pet.entity';

@Entity('ai_scans')
export class AiScan {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  type: string; // e.g., 'Stool' or 'Fur'

  @Column()
  result: string; // e.g., 'Soft-Poop'

  @Column('float')
  confidence: number;

  @CreateDateColumn()
  scannedAt: Date;

  @ManyToOne(() => Pet, (pet) => pet.id)
  pet: Pet;
}