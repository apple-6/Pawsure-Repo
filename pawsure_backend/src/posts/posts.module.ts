// posts.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Post, PostMedia])],
  controllers: [PostsController],
  providers: [PostsService],
  exports: [PostsService],
})
export class PostsModule {}