// src/comments/comments.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentsController } from './comments.controller';
import { CommentsService } from './comments.service';
import { Comment } from './comments.entity'; // Make sure this path is correct

@Module({
  imports: [TypeOrmModule.forFeature([Comment])], // Register Entity here
  controllers: [CommentsController], // Register Controller here
  providers: [CommentsService], // Register Service here
})
export class CommentsModule {}