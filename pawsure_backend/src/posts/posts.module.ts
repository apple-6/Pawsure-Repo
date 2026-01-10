// posts.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Pet } from 'src/pet/pet.entity'; // This import is already there, good!

@Module({
  imports: [
    // Add Pet here!
    TypeOrmModule.forFeature([Post, PostMedia, Pet])
  ],
  controllers: [PostsController],
  providers: [PostsService],
  exports: [PostsService],
})
export class PostsModule {}