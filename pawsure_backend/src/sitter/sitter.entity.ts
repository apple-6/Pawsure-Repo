import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    OneToOne,
    OneToMany,
    CreateDateColumn,
    UpdateDateColumn,
    JoinColumn,
    DeleteDateColumn,
} from 'typeorm';
import { User } from '../user/user.entity';
import { Booking } from '../booking/booking.entity';
import { Review } from '../review/review.entity';

// NOTE: Define SitterStatus or import it from your enum file
// Temporary definition if you don't have a dedicated enum file:
export enum SitterStatus {
    PENDING = 'pending',
    APPROVED = 'approved',
    REJECTED = 'rejected',
}

@Entity('sitters')
export class Sitter {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'text', nullable: true })
    bio: string;

    @Column({ type: 'text', nullable: true })
    experience: string;

    @Column({ type: 'text', nullable: true })
    photo_gallery: string;

    @Column({ type: 'double precision', default: 0 })
    rating: number;

    @Column({ type: 'int', default: 0 })
    reviews_count: number;

    @Column({ type: 'simple-array', nullable: true })
    available_dates: string[];

    // --- Sitter Profile Setup Fields ---
    @Column({ nullable: true })
    address: string;

    @Column({ nullable: true })
    houseType: string;

    @Column({ type: 'boolean', default: false })
    hasGarden: boolean;

    @Column({ type: 'boolean', default: false })
    hasOtherPets: boolean;

    @Column({ nullable: true }) // URL of the uploaded ID
    idDocumentUrl: string;

    @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
    ratePerNight: number;

    @Column({
        type: 'enum',
        enum: SitterStatus,
        default: SitterStatus.PENDING,
        nullable: true,
    })
    status: SitterStatus;

    @Column({ unique: true, nullable: true })
    userId: number;

    @Column({ type: 'jsonb', nullable: true }) 
    services: any;

    @OneToOne(() => User, (user) => user.sitterProfile, { nullable: true })
    @JoinColumn({ name: 'userId' })
    user: User;

    @OneToMany(() => Booking, (booking) => booking.sitter)
    bookings: Booking[];

    @OneToMany(() => Review, (review) => review.sitter)
    reviews: Review[];

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;

    @DeleteDateColumn({ 
        type: 'timestamp', 
        nullable: true, 
        name: 'deleted_at' 
    })
    deleted_at: Date;

}
