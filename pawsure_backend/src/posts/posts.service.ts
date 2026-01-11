import { Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Pet } from '../pet/pet.entity';
import { Like } from '../likes/likes.entity';

@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(
    @InjectRepository(Post) private postRepo: Repository<Post>,
    @InjectRepository(PostMedia) private mediaRepo: Repository<PostMedia>,
    @InjectRepository(Pet) private petRepo: Repository<Pet>,
  ) {}

  /**
   * Fetches posts based on the selected tab with like status.
   */
  async findAll(tab?: string, userId?: number) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}, User: ${userId}`);

      // 1. Initialize QueryBuilder
      const query = this.postRepo.createQueryBuilder('post')
        .leftJoinAndSelect('post.user', 'user') // Join Author
        .leftJoinAndSelect('post.post_media', 'media') // Join Media
        .leftJoinAndSelect('post.pets', 'pets') // Join Pets
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

      // 3. Load counts for likes and comments
      query.loadRelationCountAndMap('post.likesCount', 'post.likes');
      query.loadRelationCountAndMap('post.commentsCount', 'post.comments');

      // 4. Check if Current User Liked the Post
      if (userId) {
        query.addSelect((subQuery) => {
          return subQuery
            .select('COUNT(l.id)', 'count')
            .from(Like, 'l')
            .where('l.postId = post.id')
            .andWhere('l.userId = :userId', { userId });
        }, 'is_liked_raw');
      }

      // 5. Execute Query
      const { entities, raw } = await query.getRawAndEntities();

      // 6. Merge Raw Data (isLiked) with Entities
      const postsWithLikeStatus = entities.map((post) => {
        // Match raw data to entity by post ID
        const rawData = raw.find((r) => 
            r.post_id === post.id || r.id === post.id || (r.post_id && parseInt(r.post_id) === post.id)
        );
        
        const isLikedCount = rawData && rawData.is_liked_raw ? parseInt(rawData.is_liked_raw) : 0;

        return {
          ...post,
          isLiked: isLikedCount > 0,
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

      const isVacancy = body.is_vacancy === 'true' || body.is_vacancy === true;
      const isUrgent = body.is_urgent === 'true' || body.is_urgent === true;
      const ratePerNight = body.rate_per_night ? parseFloat(body.rate_per_night) : null;

      if (isVacancy && (!body.start_date || !body.end_date)) {
        throw new Error('start_date and end_date are required for vacancy posts');
      }

      let petIds: number[] = [];
      const rawPetIds = body.pet_id || body.petIds; 

      if (rawPetIds) {
        if (Array.isArray(rawPetIds)) {
          petIds = rawPetIds.map(id => Number(id));
        } else if (typeof rawPetIds === 'string') {
          petIds = rawPetIds.split(',').map(id => Number(id.trim()));
        }
      }

      let selectedPets: Pet[] = [];
      if (petIds.length > 0) {
        selectedPets = await this.petRepo.findBy({ id: In(petIds) });
      }

      const newPost = this.postRepo.create({
        content: body.content,
        is_urgent: isUrgent,
        is_vacancy: isVacancy,
        rate_per_night: ratePerNight,
        userId: userId,
        start_date: body.start_date ? new Date(body.start_date) : undefined,
        end_date: body.end_date ? new Date(body.end_date) : undefined,
        pets: selectedPets,
      });

      const savedPost = await this.postRepo.save(newPost);

      if (files && files.length > 0) {
        const mediaRecords = files.map((file) => ({
          media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
          post_id: savedPost.id,
          media_type: file.mimetype.startsWith('image/') ? 'image' : 'video',
        }));
        await this.mediaRepo.save(mediaRecords);
      }

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
   */
  /**
   * Updates an existing post (including Media logic).
   */
  // 1. Add 'files' to the arguments so we can receive new uploads
  async update(id: number, body: any, userId: number, files?: Express.Multer.File[]) {
    try {
      const post = await this.postRepo.findOne({
        where: { id },
        relations: ['pets', 'post_media'],
      });
  
      if (!post) throw new NotFoundException(`Post with ID ${id} not found`);
      if (post.userId !== userId) throw new UnauthorizedException('Permission denied');
  
      // --- 1. Handle Pet Updates (Many-to-Many) ---
      if (body.pet_id || body.petIds) {
        let petIds: number[] = [];
        const rawPetIds = body.pet_id || body.petIds;
        
        if (Array.isArray(rawPetIds)) {
          petIds = rawPetIds.map(Number).filter(id => !isNaN(id));
        } else if (rawPetIds) {
          petIds = String(rawPetIds)
            .split(',')
            .map(id => Number(id.trim()))
            .filter(id => !isNaN(id));
        }
  
        if (petIds.length > 0) {
          // Fetch the actual Pet entities
          const pets = await this.petRepo.findBy({ id: In(petIds) });
          if (pets.length > 0) {
            post.pets = pets; // Assign the Pet entities
          }
        } else {
          post.pets = []; // Clear pets if no IDs provided
        }
      }
  
      // --- 2. Handle Text & Boolean Updates ---
      post.content = body.content ?? post.content;
      post.rate_per_night = body.rate_per_night ? parseFloat(body.rate_per_night) : post.rate_per_night;
      post.start_date = body.start_date ? new Date(body.start_date) : post.start_date;
      post.end_date = body.end_date ? new Date(body.end_date) : post.end_date;
      post.is_urgent = body.is_urgent !== undefined ? (body.is_urgent === 'true' || body.is_urgent === true) : post.is_urgent;
  
      // Save basic updates + many-to-many relations
      const updatedPost = await this.postRepo.save(post);
  
      // --- 3. Handle Existing Media (Deletions) ---
      if (body.existingMedia) {
        const keptMediaUrls: string[] = JSON.parse(body.existingMedia);
        const mediaToDelete = updatedPost.post_media.filter(
          (m) => !keptMediaUrls.includes(m.media_url)
        );
  
        if (mediaToDelete.length > 0) {
          await this.mediaRepo.remove(mediaToDelete);
        }
      }
  
      // --- 4. Handle New Media (Uploads) ---
      if (files && files.length > 0) {
        const baseUrl = 'http://localhost:3000';
        const newMediaRecords = files.map((file) =>
          this.mediaRepo.create({
            media_url: `${baseUrl}/uploads/post-media/${file.filename}`,
            post_id: updatedPost.id,
            media_type: file.mimetype.startsWith('image/') ? 'image' : 'video',
          })
        );
  
        await this.mediaRepo.save(newMediaRecords);
      }
  
      // Return the fresh post with updated relations
      return await this.postRepo.findOne({
        where: { id: updatedPost.id },
        relations: ['user', 'post_media', 'pets'],
      });
  
    } catch (error) {
      this.logger.error(`❌ Update Error: ${error.message}`);
      this.logger.error(`❌ Stack: ${error.stack}`);
      throw error;
    }
  }

  /**
   * Removes a post.
   */
  async remove(id: number, userId: number) {
    try {
      const post = await this.postRepo.findOne({ where: { id } });
      if (!post) throw new NotFoundException(`Post not found`);
      if (post.userId !== userId) throw new UnauthorizedException('Permission denied');

      await this.postRepo.remove(post);
      return { success: true };
    } catch (error) {
      this.logger.error(`❌ Delete Error: ${error.message}`);
      throw error;
    }
  }
}