import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommunityController } from './community.controller';
import { CommunityService } from './community.service';
import { Post } from '../posts/posts.entity';
import { PostMedia } from '../posts/post-media.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Post, PostMedia])],
  controllers: [CommunityController],
  providers: [CommunityService],
  exports: [CommunityService],
})
export class CommunityModule {}