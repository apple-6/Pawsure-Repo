import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from './posts.entity';
import { PostsService } from './posts.service';
import { PostMedia } from './post-media.entity'; // ✅ Imported

@Module({
  imports: [
    // ✅ Register both Post and PostMedia so autoLoadEntities can find them
    TypeOrmModule.forFeature([Post, PostMedia]), 
  ],
  providers: [PostsService],
  exports: [PostsService],
})
export class PostsModule {}