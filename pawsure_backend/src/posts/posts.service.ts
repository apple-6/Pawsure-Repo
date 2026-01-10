import { Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Pet } from '../pet/pet.entity';
import { Like } from '../likes/likes.entity'; // ✅ Import your Like entity

@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(
    @InjectRepository(Post) private postRepo: Repository<Post>,
    @InjectRepository(PostMedia) private mediaRepo: Repository<PostMedia>,
    @InjectRepository(Pet) private petRepo: Repository<Pet>,
  ) {}

  /**
   * Fetches posts based on the selected tab.
   */
  async findAll(tab?: string, userId?: number) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}, User: ${userId}`);

  //     let where: any = {};

      if (tab === 'vacancy') {
        where.is_vacancy = true;
      } else if (tab === 'urgent') {
        where.is_urgent = true;
        where.is_vacancy = false;
      } else {
        where.is_vacancy = false;
      }

      const posts = await this.postRepo.find(
        where,
        relations: ['user', 'post_media', 'pets'], 
        order: { created_at: 'DESC' },
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

      query.loadRelationCountAndMap('post.commentsCount', 'post.comments');

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
   */
  async create(body: any, files: Express.Multer.File[], userId: number) {
    try {
      this.logger.log(`📝 Creating post for user ${userId}`);

      // 1. Normalize Boolean and Numeric fields
      const isVacancy = body.is_vacancy === 'true' || body.is_vacancy === true;
      const isUrgent = body.is_urgent === 'true' || body.is_urgent === true;
      const ratePerNight = body.rate_per_night ? parseFloat(body.rate_per_night) : null;

      if (isVacancy && (!body.start_date || !body.end_date)) {
        throw new Error('start_date and end_date are required for vacancy posts');
      }

      // 2. Handle Pet IDs (supports Array or comma-separated String)
      let petIds: number[] = [];
      // Check for 'pet_id' to match your Flutter code
      const rawPetIds = body.pet_id || body.petIds; 

      if (rawPetIds) {
        if (Array.isArray(rawPetIds)) {
          petIds = rawPetIds.map(id => Number(id));
        } else if (typeof rawPetIds === 'string') {
          petIds = rawPetIds.split(',').map(id => Number(id.trim()));
        }
      }

      // 3. Fetch Pet Entities if IDs exist
      let selectedPets: Pet[] = [];
      if (petIds.length > 0) {
        selectedPets = await this.petRepo.findBy({
          id: In(petIds),
        });
      }

      // 4. Prepare and Save the Post Entity
      const newPost = this.postRepo.create({
        content: body.content,
        is_urgent: isUrgent,
        is_vacancy: isVacancy,
        rate_per_night: ratePerNight, // New Field Added
        userId: userId,
        start_date: body.start_date ? new Date(body.start_date) : undefined,
        end_date: body.end_date ? new Date(body.end_date) : undefined,
        pets: selectedPets,
      });

      const savedPost = await this.postRepo.save(newPost);

      // 5. Handle media uploads
      if (files && files.length > 0) {
        const mediaRecords = files.map((file) => ({
          media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
          post_id: savedPost.id,
          media_type: file.mimetype.startsWith('image/') ? 'image' : 'video',
        }));
        await this.mediaRepo.save(mediaRecords);
      }

      this.logger.log(`✅ Post created with ID: ${savedPost.id}`);

      // 6. Return the post with all relations
      return await this.postRepo.findOne({
        where: { id: savedPost.id },
        relations: ['user', 'post_media', 'pets'],
      });

    } catch (error) {
      this.logger.error(`❌ Error creating post: ${error.message}`);
      throw new Error(`Failed to create post: ${error.message}`);
    }
  }
  /**
   * Updates an existing post.
   * Includes ownership check to ensure only the creator can edit.
   */
  async update(id: number, body: any, userId: number) {
    try {
      this.logger.log(`Update request for post ${id} by user ${userId}`);

      // 1. Find existing post with current pet relations
      const post = await this.postRepo.findOne({
        where: { id },
        relations: ['pets'],
      });

      if (!post) {
        throw new NotFoundException(`Post with ID ${id} not found`);
      }

      // 2. Ownership Check: Ensure userId matches creator
      if (post.userId !== userId) {
        throw new UnauthorizedException('You do not have permission to edit this post');
      }

      // 3. Handle Pet Updates (if provided)
      if (body.pet_id || body.petIds) {
        let petIds: number[] = [];
        const rawPetIds = body.pet_id || body.petIds;

        if (Array.isArray(rawPetIds)) {
          petIds = rawPetIds.map(id => Number(id));
        } else if (typeof rawPetIds === 'string') {
          try {
            const parsed = JSON.parse(rawPetIds);
            petIds = Array.isArray(parsed) ? parsed.map(Number) : [Number(parsed)];
          } catch {
            petIds = rawPetIds.split(',').map(id => Number(id.trim()));
          }
        }

        if (petIds.length > 0) {
          post.pets = await this.petRepo.findBy({ id: In(petIds) });
        }
      }

      // 4. Update other fields
      post.content = body.content ?? post.content;
      post.rate_per_night = body.rate_per_night ? parseFloat(body.rate_per_night) : post.rate_per_night;
      post.start_date = body.start_date ? new Date(body.start_date) : post.start_date;
      post.end_date = body.end_date ? new Date(body.end_date) : post.end_date;
      post.is_urgent = body.is_urgent !== undefined ? (body.is_urgent === 'true' || body.is_urgent === true) : post.is_urgent;

      // 5. Save updated entity
      const updatedPost = await this.postRepo.save(post);
      this.logger.log(`✅ Post ${id} updated successfully`);

      return await this.postRepo.findOne({
        where: { id: updatedPost.id },
        relations: ['user', 'post_media', 'pets'],
      });
    } catch (error) {
      this.logger.error(`❌ Update Error: ${error.message}`);
      throw error;
    }
  }

  /**
   * Removes a post.
   * Includes ownership check to ensure only the creator can delete.
   */
  async remove(id: number, userId: number) {
    try {
      this.logger.log(`Delete request for post ${id} by user ${userId}`);

      const post = await this.postRepo.findOne({ where: { id } });

      if (!post) {
        throw new NotFoundException(`Post with ID ${id} not found`);
      }

      // Ownership Check
      if (post.userId !== userId) {
        throw new UnauthorizedException('You do not have permission to delete this post');
      }

      // Note: If you have Cascade Delete set in your Entity, 
      // related media records will be deleted automatically.
      await this.postRepo.remove(post);
      this.logger.log(`✅ Post ${id} deleted successfully`);
      
      return { success: true };
    } catch (error) {
      this.logger.error(`❌ Delete Error: ${error.message}`);
      throw error;
    }
  }
}