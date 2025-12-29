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

  /**
   * Fetches posts based on the selected tab.
   * Handles filtering to separate social feed from job vacancies.
   */
  async findAll(tab?: string) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}`);

      const query = this.postRepo
        .createQueryBuilder('post')
        .leftJoinAndSelect('post.user', 'user')
        .leftJoinAndSelect('post.post_media', 'media');

      // Logic to separate Vacancies from the Social Feed
      if (tab === 'vacancy') {
        // ONLY show jobs
        query.andWhere('post.is_vacancy = :vacancy', { vacancy: true });
        this.logger.log('💼 Filtering: Sitter Vacancies only');
      } else if (tab === 'urgent') {
        // ONLY show urgent social posts
        query.andWhere('post.is_urgent = :urgent', { urgent: true });
        query.andWhere('post.is_vacancy = :vacancy', { vacancy: false });
        this.logger.log('⚡ Filtering: Urgent Social Posts only');
      } else {
        // DEFAULT (For You): Show social posts, hide job vacancies
        query.andWhere('post.is_vacancy = :vacancy', { vacancy: false });
        this.logger.log('📱 Filtering: Standard Social Feed');
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

  /**
   * Creates a new post or vacancy.
   * Extracts vacancy-specific fields from the request body.
   */
  async create(body: any, files: Express.Multer.File[], userId: number) {
    try {
      this.logger.log(`📝 Creating post for user ${userId}`);

      // Parse booleans correctly (Multipart-form sends everything as strings)
      const isVacancy = body.is_vacancy === 'true' || body.is_vacancy === true;
      const isUrgent = body.is_urgent === 'true' || body.is_urgent === true;

      // 1. Create the post object with vacancy fields
      const postData = this.postRepo.create({
        content: body.content,
        is_urgent: isUrgent,
        is_vacancy: isVacancy,
        userId: userId,
        // Ensure these fields exist in your posts.entity.ts
        start_date: body.start_date ? new Date(body.start_date) : null,
        end_date: body.end_date ? new Date(body.end_date) : null,
        pet_id: body.petId || null, 
      });

      // 2. Save the post
      const savedPost: Post = await this.postRepo.save(postData);
      this.logger.log(`✅ Post created with ID: ${savedPost.id} (IsVacancy: ${isVacancy})`);

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