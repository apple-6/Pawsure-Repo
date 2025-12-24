// src/data-source.ts

import 'dotenv/config'; // Loads .env file
import { DataSource } from 'typeorm';

// Import all your entities
import { User } from './user/user.entity';
import { Pet } from './pet/pet.entity';
import { Booking } from './booking/booking.entity';
import { Notification } from './notification/notification.entity';
import { Review } from './review/review.entity';
import { Sitter } from './sitter/sitter.entity';
import { Post } from './posts/posts.entity';
import { Comment } from './comments/comments.entity';
import { Like } from './likes/likes.entity';
import { ActivityLog } from './activity-log/activity-log.entity';
import { HealthRecord } from './health-record/health-record.entity';
import { Payment } from './payment/payment.entity';
import { Event } from './events/entities/event.entity';
import { PostMedia } from './posts/post-media.entity';


// This is the configuration for the CLI
const AppDataSource = new DataSource({
  type: 'postgres',

  // --- THIS IS THE MAGIC ---
  // It reads the single DATABASE_URL from your .env file
  url: process.env.DATABASE_URL,
  
  // --- THIS IS REQUIRED FOR SUPABASE ---
  // It tells Postgres to connect securely
  ssl: {
    rejectUnauthorized: false,
  },
  // ---------------------------------
  
  synchronize: false, // Must be false for migrations
  logging: true,
  
  entities: [
    User,
    Pet,
    Booking,
    Notification,
    Review,
    Sitter,
    Post,
    Comment,
    Like,
    ActivityLog,
    HealthRecord,
    Payment,
    Event,
    PostMedia
  ],
  
  migrations: [__dirname + '/migrations/*.ts'],
});

export default AppDataSource;
