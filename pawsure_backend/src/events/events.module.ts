// pawsure_backend/src/events/events.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EventsService } from './events.service';
import { EventsController } from './events.controller'; // 👈 FIXED: Correct path
import { Event } from './entities/event.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Event])], 
  controllers: [EventsController],
  providers: [EventsService],
  exports: [EventsService],
})
export class EventsModule {}