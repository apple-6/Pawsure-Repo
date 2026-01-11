import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, Index, JoinColumn } from 'typeorm';
import { Pet } from '../pet/pet.entity';

@Entity('meal_logs')
@Index(['petId', 'log_date', 'meal_type'], { unique: true })
export class MealLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'pet_id' })
  petId: number;

  @Column({ type: 'date' })
  log_date: Date;

  @Column()
  meal_type: string; // e.g., 'Breakfast', 'Dinner', 'Snack'

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => Pet, (pet) => pet.mealLogs, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pet_id' })
  pet: Pet;
}