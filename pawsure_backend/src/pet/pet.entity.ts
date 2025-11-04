import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
<<<<<<< HEAD
  JoinColumn, // Added for clarity on foreign key
=======
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
} from 'typeorm';
import { User } from '../user/user.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { HealthRecord } from '../health-record/health-record.entity';
import { Booking } from '../booking/booking.entity';

@Entity('pets')
export class Pet {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

<<<<<<< HEAD
  // --- ADDITIONS FOR THE USER STORY (PHOTO URL) ---
  @Column({ nullable: true }) // 'STRING photoUrl' - New column for the pet's photo URL
  photoUrl: string;
  // --------------------------------------------------

  @Column({ nullable: true }) // 'STRING species'
=======
  @Column({ nullable: true })
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
  species: string;

  @Column()
  breed: string;

<<<<<<< HEAD
  @Column({ type: 'date', nullable: true }) // 'DATE dob'
=======
  @Column({ type: 'date', nullable: true })
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
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

<<<<<<< HEAD
  // --- Relationships ---

  // Explicit foreign key column for the owner
  @Column() // 'INT ownerId FK' - Explicit column for the foreign key
  ownerId: number; 

  @ManyToOne(() => User, (user) => user.pets) // 'INT user_id FK'
  @JoinColumn({ name: 'ownerId' }) // Tells TypeORM to use the 'ownerId' column as the foreign key
=======
  @ManyToOne(() => User, (user) => user.pets)
  @JoinColumn({ name: 'ownerId' })
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
  owner: User;

  @OneToMany(() => ActivityLog, (activityLog) => activityLog.pet)
  activityLogs: ActivityLog[];

  @OneToMany(() => HealthRecord, (healthRecord) => healthRecord.pet)
  healthRecords: HealthRecord[];

  @OneToMany(() => Booking, (booking) => booking.pet)
  bookings: Booking[];

  @CreateDateColumn()
  created_at: Date;

<<<<<<< HEAD
  @OneToMany(() => HealthRecord, (record) => record.pet)
  healthRecords: HealthRecord[];
=======
  @UpdateDateColumn()
  updated_at: Date;
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
}