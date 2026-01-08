import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Like } from '../likes/likes.entity'; // ✅ Import your Like entity

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
  async findAll(tab?: string, userId?: number) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}, User: ${userId}`);

  //     let where: any = {};

  //     // Logic to separate Vacancies from the Social Feed
  //     if (tab === 'vacancy') {
  //       // ONLY show jobs
  //       where.is_vacancy = true;
  //       this.logger.log('💼 Filtering: Sitter Vacancies only');
  //     } else if (tab === 'urgent') {
  //       // ONLY show urgent social posts
  //       where.is_urgent = true;
  //       where.is_vacancy = false;
  //       this.logger.log('⚡ Filtering: Urgent Social Posts only');
  //     } else {
  //       // DEFAULT (For You): Show social posts, hide job vacancies
  //       where.is_vacancy = false;
  //       this.logger.log('📱 Filtering: Standard Social Feed');
  //     }

  //     const posts = await this.postRepo.find({
  //       where,
  //       relations: ['user', 'post_media'],
  //       order: { created_at: 'DESC' },
  //     });

  //     this.logger.log(`✅ Successfully fetched ${posts.length} posts`);
  //     return posts;
  //   } catch (error) {
  //     this.logger.error(
  //       `❌ Error fetching posts: ${error.message}`,
  //       error.stack,
  //     );
  //     throw new Error(`Failed to load posts: ${error.message}`);
  //   }
  // }
  // 1. Start QueryBuilder
      const query = this.postRepo.createQueryBuilder('post')
        .leftJoinAndSelect('post.user', 'user') // Join Author
        .leftJoinAndSelect('post.post_media', 'media') // Join Media
        .orderBy('post.created_at', 'DESC');

      // 2. Apply Filters (Tab Logic)
      if (tab === 'vacancy') {
        query.andWhere('post.is_vacancy = :isVacancy', { isVacancy: true });
        this.logger.log('💼 Filtering: Sitter Vacancies only');
      } else if (tab === 'urgent') {
        query.andWhere('post.is_urgent = :isUrgent', { isUrgent: true });
        query.andWhere('post.is_vacancy = :isVacancy', { isVacancy: false });
        this.logger.log('⚡ Filtering: Urgent Social Posts only');
      } else {
        query.andWhere('post.is_vacancy = :isVacancy', { isVacancy: false });
        this.logger.log('📱 Filtering: Standard Social Feed');
      }

      // 3. Get Total Likes Count
      // This maps the count of the 'likes' relation to a property 'likesCount' on the Post object
      query.loadRelationCountAndMap('post.likesCount', 'post.likes');

      // 4. Check if Current User Liked the Post
      // We use addSelect with a subquery. If count > 0, it returns "1", else "0".
      if (userId) {
        query.addSelect((subQuery) => {
          return subQuery
            .select('COUNT(l.id)', 'count')
            .from(Like, 'l') // querying the 'likes' table
            //.where('l.post_id = post.id')
            .where('l.postId = post.id')
            //.andWhere('l.user_id = :userId', { userId });
            .andWhere('l.userId = :userId', { userId });
        }, 'is_liked_raw'); // This alias 'is_liked_raw' will be in the raw results
      }

      // 5. Execute Query
      // getRawAndEntities gives us the clean Post objects AND the raw data (including our subquery result)
      const { entities, raw } = await query.getRawAndEntities();

      // 6. Merge Data
      // We need to map the "is_liked_raw" string from raw data into a boolean on the entity
      const postsWithLikeStatus = entities.map((post) => {
        // Find the raw data row corresponding to this post
        const rawData = raw.find((r) => r.post_id === post.id);
        
        // Check our alias. Note: Database drivers might return string "1" or number 1.
        const isLikedCount = rawData ? parseInt(rawData.is_liked_raw) : 0;

        return {
          ...post,
          isLiked: isLikedCount > 0, // ✅ Convert to boolean for Frontend
        };
      });

      this.logger.log(`✅ Fetched ${postsWithLikeStatus.length} posts`);
      return postsWithLikeStatus;

    } catch (error) {
      this.logger.error(`❌ Error fetching posts: ${error.message}`, error.stack);
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