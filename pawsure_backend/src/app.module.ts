// pawsure_backend/src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiModule } from './ai/ai.module';
import { UserModule } from './user/user.module';
import { PetModule } from './pet/pet.module';
import { SitterModule } from './sitter/sitter.module';
import { BookingModule } from './booking/booking.module';
import { PaymentModule } from './payment/payment.module';
import { PaymentMethodModule } from './payment-method/payment-method.module';
import { ActivityLogModule } from './activity-log/activity-log.module';
import { HealthRecordModule } from './health-record/health-record.module';
import { ReviewModule } from './review/review.module';
import { NotificationModule } from './notification/notification.module';
import { PostsModule } from './posts/posts.module';
import { CommunityModule } from './community/community.module';
import { CommentsModule } from './comments/comments.module';
import { LikesModule } from './likes/likes.module';
import { RoleModule } from './role/role.module';
import { AuthModule } from './auth/auth.module';
import { FileService } from './file/file.service';
import { FileModule } from './file/file.module';
import { EventsModule } from './events/events.module';
import { ChatModule } from './chat/chat.module';
import { MoodLogModule } from './mood-log/mood-log.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        url: configService.get<string>('DATABASE_URL'),
        autoLoadEntities: true,
        synchronize: false, // ✅ Manual schema changes for safety
        ssl: {
          rejectUnauthorized: false,
        },
      }),
    }),
    AiModule,
    UserModule,
    PetModule,
    SitterModule,
    BookingModule,
    PaymentModule,
    PaymentMethodModule,
    ActivityLogModule,
    HealthRecordModule,
    ReviewModule,
    NotificationModule,
    PostsModule,
    CommunityModule,
    CommentsModule,
    LikesModule,
    FileModule,
    RoleModule,
    AuthModule,
    EventsModule,
    ChatModule,
    MoodLogModule, // 🆕 Mood & Streak tracking
  ],
  controllers: [AppController],
  providers: [AppService, FileService],
})
export class AppModule {}
