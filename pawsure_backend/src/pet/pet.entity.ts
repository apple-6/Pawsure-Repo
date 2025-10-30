// src/pet/pet.entity.ts
import { ActivityLog } from 'src/activity-log/activity-log.entity';
import { Booking } from 'src/booking/booking.entity';
import { HealthRecord } from 'src/health-record/health-record.entity';
import { User } from 'src/user/user.entity';
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn, // Added for clarity on foreign key
} from 'typeorm';

@Entity('pets')
export class Pet {
  @PrimaryGeneratedColumn() // 'INT pet_id PK'
  id: number;

  @Column() // 'STRING name'
  name: string;

  // --- ADDITIONS FOR THE USER STORY (PHOTO URL) ---
  @Column({ nullable: true }) // 'STRING photoUrl' - New column for the pet's photo URL
  photoUrl: string;
  // --------------------------------------------------

  @Column() // 'STRING species'
  species: string;

  @Column() // 'STRING breed'
  breed: string;

  @Column({ type: 'date' }) // 'DATE dob'
  dob: string;

  @Column({ type: 'float', nullable: true }) // 'FLOAT weight'
  weight: number;

  @Column({ type: 'text', nullable: true }) // 'TEXT allergies'
  allergies: string;

  @Column({ type: 'date', array: true, nullable: true }) // 'DATE[] vaccination_dates'
  vaccination_dates: string[];

  @Column({ type: 'date', nullable: true }) // 'DATE last_vet_visit'
  last_vet_visit: string;

  @Column({ type: 'float', nullable: true }) // 'FLOAT mood_rating'
  mood_rating: number;

  @Column({ default: 0 }) // 'INT streak'
  streak: number;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---

  // Explicit foreign key column for the owner
  @Column() // 'INT ownerId FK' - Explicit column for the foreign key
  ownerId: number; 

  @ManyToOne(() => User, (user) => user.pets) // 'INT user_id FK'
  @JoinColumn({ name: 'ownerId' }) // Tells TypeORM to use the 'ownerId' column as the foreign key
  owner: User;

  @OneToMany(() => Booking, (booking) => booking.pet)
  bookings: Booking[];

  @OneToMany(() => ActivityLog, (log) => log.pet)
  activityLogs: ActivityLog[];

  @OneToMany(() => HealthRecord, (record) => record.pet)
  healthRecords: HealthRecord[];
}