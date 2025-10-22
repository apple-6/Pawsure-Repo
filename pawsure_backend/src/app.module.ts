import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config'; // Import ConfigModule and ConfigService
import { TypeOrmModule } from '@nestjs/typeorm'; // Import TypeOrmModule
import { AiModule } from './ai/ai.module'; // Import your existing AI module

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
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}