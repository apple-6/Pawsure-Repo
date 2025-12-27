import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';

@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(
    @InjectRepository(Post) private postRepo: Repository<Post>,
    @InjectRepository(PostMedia) private mediaRepo: Repository<PostMedia>,
  ) {}

  async findAll(tab?: string) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}`);

      const query = this.postRepo
        .createQueryBuilder('post')
        .leftJoinAndSelect('post.user', 'user')
        .leftJoinAndSelect('post.post_media', 'media');

      if (tab === 'urgent') {
        query.where('post.is_urgent = :urgent', { urgent: true });
        this.logger.log('⚡ Filtering for urgent posts only');
      }

      const posts = await query.orderBy('post.created_at', 'DESC').getMany();

      this.logger.log(`✅ Successfully fetched ${posts.length} posts`);
      return posts;
    } catch (error) {
      this.logger.error(
        `❌ Error fetching posts: ${error.message}`,
        error.stack,
      );
      throw new Error(`Failed to load posts: ${error.message}`);
    }
  }

  async create(body: any, files: Express.Multer.File[], userId: number) {
    try {
      this.logger.log(`📝 Creating post for user ${userId}`);

      // 1. Create the post object
      const postData = this.postRepo.create({
        content: body.content,
        is_urgent: body.is_urgent === 'true' || body.is_urgent === true,
        userId: userId,
      });

      // 2. Save the post
      const savedPost: Post = await this.postRepo.save(postData);
      this.logger.log(`✅ Post created with ID: ${savedPost.id}`);

      // 3. Handle media uploads
      if (files && files.length > 0) {
        this.logger.log(`📁 Saving ${files.length} media files`);

        const mediaRecords = files.map((file) => {
          const mediaType = file.mimetype.startsWith('image/')
            ? 'image'
            : 'video';
          return {
            media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
            post_id: savedPost.id,
            media_type: mediaType,
          };
        });

        await this.mediaRepo.save(mediaRecords);
        this.logger.log(`✅ Saved ${mediaRecords.length} media files`);
      }

      // 4. Return the post with relations loaded
      const fullPost = await this.postRepo.findOne({
        where: { id: savedPost.id },
        relations: ['user', 'post_media'],
      });

      return fullPost;
    } catch (error) {
      this.logger.error(
        `❌ Error creating post: ${error.message}`,
        error.stack,
      );
      throw new Error(`Failed to create post: ${error.message}`);
    }
  }
}