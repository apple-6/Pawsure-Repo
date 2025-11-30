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
import { Event } from '../events/entities/event.entity'; // 🆕 IMPORT

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

  @Column({ type: 'text', nullable: true })
  allergies: string;

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

  @OneToMany(() => Booking, (booking) => booking.pet)
  bookings: Booking[];

  // 🆕 NEW RELATIONSHIP
  @OneToMany(() => Event, (event) => event.pet)
  events: Event[];

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}