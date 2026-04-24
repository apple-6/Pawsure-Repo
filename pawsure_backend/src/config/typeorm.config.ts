import { DataSourceOptions } from 'typeorm';
import { ConfigService } from '@nestjs/config';

// Import all entities
import { User } from '../user/user.entity';
import { Pet } from '../pet/pet.entity';
import { Booking } from '../booking/booking.entity';
import { Notification } from '../notification/notification.entity';
import { Review } from '../review/review.entity';
import { Sitter } from '../sitter/sitter.entity';
import { Post } from '../posts/posts.entity';
import { Comment } from '../comments/comments.entity';
import { Like } from '../likes/likes.entity';
import { ActivityLog } from '../activity-log/activity-log.entity';
import { HealthRecord } from '../health-record/health-record.entity';
import { Payment } from '../payment/payment.entity';
import { PaymentMethod } from '../payment-method/payment-method.entity';
import { Event } from '../events/entities/event.entity';
import { PostMedia } from '../posts/post-media.entity';

export const getTypeOrmConfig = (configService: ConfigService): DataSourceOptions => ({
  type: 'postgres',
  url: configService.get<string>('DATABASE_URL'),
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
    PaymentMethod,
    Event,
    PostMedia,
  ],
  migrations: [__dirname + '/../migrations/*.ts'],
  synchronize: false, // Always use migrations for safety
  logging: configService.get<string>('NODE_ENV') === 'development',
  ssl: {
    rejectUnauthorized: false,
  },
});
