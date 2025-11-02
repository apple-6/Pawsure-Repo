import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config'; // Import ConfigModule and ConfigService
import { TypeOrmModule } from '@nestjs/typeorm'; // Import TypeOrmModule
import { AiModule } from './ai/ai.module'; // Import your existing AI module
import { UserModule } from './user/user.module';
import { PetModule } from './pet/pet.module';
import { SitterModule } from './sitter/sitter.module';
import { BookingModule } from './booking/booking.module';
import { PaymentModule } from './payment/payment.module';
import { ActivityLogModule } from './activity-log/activity-log.module';
import { HealthRecordModule } from './health-record/health-record.module';
import { ReviewModule } from './review/review.module';
import { NotificationModule } from './notification/notification.module';
import { PostsModule } from './posts/posts.module';
import { CommentsModule } from './comments/comments.module';
import { LikesModule } from './likes/likes.module';
import { RoleModule } from './role/role.module';


@Module({
  imports: [
    ConfigModule.forRoot({ // Configure ConfigModule first
      isGlobal: true,      // Make config available globally
      envFilePath: '.env', // Specify the .env file
    }),
    
    TypeOrmModule.forRootAsync({ // Configure TypeOrm asynchronously
      imports: [ConfigModule],   // Import ConfigModule here
      inject: [ConfigService],   // Inject ConfigService to read env vars
      useFactory: (configService: ConfigService) => ({
        type: 'postgres', // Database type
        url: configService.get<string>('DATABASE_URL'), // Get URL from .env
        autoLoadEntities: true, // Automatically load your table models (Entities)
        synchronize: true, // DEV ONLY: Auto-create/update tables (Disable in production!)
        ssl: { // Required for Supabase/cloud connections
          rejectUnauthorized: false
        }
      }),
    }),
    AiModule, // Include your AI module
    // Add other feature modules here later (e.g., PetsModule, UsersModule)
    AiModule,
    UserModule,
    PetModule,
    SitterModule,
    BookingModule,
    PaymentModule,
    ActivityLogModule,
    HealthRecordModule,
    ReviewModule,
    NotificationModule,
    PostsModule,
    CommentsModule,
    LikesModule,

    RoleModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}