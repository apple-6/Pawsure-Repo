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
import { ActivityLogModule } from './activity-log/activity-log.module';
import { HealthRecordModule } from './health-record/health-record.module';
import { ReviewModule } from './review/review.module';
import { NotificationModule } from './notification/notification.module';
import { PostsModule } from './posts/posts.module';
import { CommentsModule } from './comments/comments.module';
import { LikesModule } from './likes/likes.module';
import { RoleModule } from './role/role.module';
import { AuthModule } from './auth/auth.module';
<<<<<<< HEAD
import { FileService } from './file/file.service';
import { FileModule } from './file/file.module';
=======
import { EventsModule } from './events/events.module'; // 👈 Correct Import
>>>>>>> fff8443f8b89299d113154623b7961e3a6d92706

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
        synchronize: true, // Set to false in production
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
    ActivityLogModule,
    HealthRecordModule,
    ReviewModule,
    NotificationModule,
    PostsModule,
    CommentsModule,
    LikesModule,
<<<<<<< HEAD
  RoleModule,
  AuthModule,
  FileModule,
=======
    RoleModule,
    AuthModule,
    EventsModule, // 👈 Added here
>>>>>>> fff8443f8b89299d113154623b7961e3a6d92706
  ],
  controllers: [AppController],
  providers: [AppService, FileService],
})
export class AppModule {}