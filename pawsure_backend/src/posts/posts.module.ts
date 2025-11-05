import { Module } from '@nestjs/common';
import { PostsService } from './posts.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from './posts.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Post])],
  providers: [PostsService],
  exports: [PostsService]
})
export class PostsModule {}
