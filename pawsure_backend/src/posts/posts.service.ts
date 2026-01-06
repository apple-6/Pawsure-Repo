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

      let where: any = {};

      // Logic to separate Vacancies from the Social Feed
      if (tab === 'vacancy') {
        // ONLY show jobs
        where.is_vacancy = true;
        this.logger.log('💼 Filtering: Sitter Vacancies only');
      } else if (tab === 'urgent') {
        // ONLY show urgent social posts
        where.is_urgent = true;
        where.is_vacancy = false;
        this.logger.log('⚡ Filtering: Urgent Social Posts only');
      } else {
        // DEFAULT (For You): Show social posts, hide job vacancies
        where.is_vacancy = false;
        this.logger.log('📱 Filtering: Standard Social Feed');
      }

      const posts = await this.postRepo.find({
        where,
        relations: ['user', 'post_media'],
        order: { created_at: 'DESC' },
      });

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

      // Validate required fields for vacancies
      if (isVacancy) {
        if (!body.start_date || !body.end_date) {
          throw new Error('start_date and end_date are required for vacancy posts');
        }
      }

      // Create post object with proper typing
      const postData: Partial<Post> = {
        content: body.content,
        is_urgent: isUrgent,
        is_vacancy: isVacancy,
        userId: userId,  // ✅ Use camelCase property name (maps to user_id column)
        // For vacancies, dates are required. For social posts, they're optional
        start_date: body.start_date ? new Date(body.start_date) : undefined,
        end_date: body.end_date ? new Date(body.end_date) : undefined,
        pet_id: body.petId || null,
      };

      // Save the post
      const savedPost = await this.postRepo.save(postData);
      this.logger.log(`✅ Post created with ID: ${savedPost.id} (IsVacancy: ${isVacancy})`);

      // Handle media uploads
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

      // Return the post with relations loaded
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