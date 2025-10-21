import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      // <-- Add this

      isGlobal: true, // Makes config available everywhere
    }),
    AiModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
