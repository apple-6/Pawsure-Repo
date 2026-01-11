// pawsure_backend/src/pet/pet.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from '../user/user.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { HealthRecord } from '../health-record/health-record.entity';
import { Booking } from '../booking/booking.entity';
import { Event } from '../events/entities/event.entity';
import { MoodLog } from '../mood-log/mood-log.entity';
import { MealLog } from '../meal-log/meal-log.entity';


@Entity('pets')
export class Pet {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ nullable: true })
  species: string;

  @Column()
  breed: string;

  @Column({ type: 'date', nullable: true })
  dob: Date;

  @Column({ type: 'double precision', nullable: true })
  weight: number;

  @Column({ type: 'double precision', nullable: true })
  height: number;

  @Column({ type: 'int', nullable: true })
  body_condition_score: number;

  @Column({ type: 'jsonb', nullable: true })
  weight_history: { date: string; weight: number }[];

  @Column({ type: 'text', nullable: true })
  allergies: string;

  @Column({ nullable: true })
  food_brand: string;

  @Column({ nullable: true })
  daily_food_amount: string;

  // 🔧 ADD THIS COLUMN
  @Column({ nullable: true, default: 'unknown' })
  sterilization_status: string;

  @Column({ type: 'simple-array', nullable: true })
  vaccination_dates: string[];

  @Column({ type: 'date', nullable: true })
  last_vet_visit: Date;

  @Column({ type: 'double precision', nullable: true })
  mood_rating: number;

  @Column({ type: 'int', default: 0 })
  streak: number;

  @Column({ nullable: true })
  photoUrl: string;

  @Column()
  ownerId: number;

  @ManyToOne(() => User, (user) => user.pets)
  @JoinColumn({ name: 'ownerId' })
  owner: User;

  @OneToMany(() => ActivityLog, (activityLog) => activityLog.pet)
  activityLogs: ActivityLog[];

  @OneToMany(() => HealthRecord, (healthRecord) => healthRecord.pet)
  healthRecords: HealthRecord[];

  @OneToMany(() => Booking, (booking) => booking.pets)
  bookings: Booking[];

  @OneToMany(() => Event, (event) => event.pet)
  events: Event[];

  @OneToMany(() => MoodLog, (moodLog) => moodLog.pet)
  moodLogs: MoodLog[];

  // 🆕 Meal logs relationship
  @OneToMany(() => MealLog, (mealLog) => mealLog.pet)
  mealLogs: MealLog[];

  // 🆕 Last activity date for streak calculation
  @Column({ type: 'date', nullable: true })
  last_activity_date: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}