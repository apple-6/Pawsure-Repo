import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Pet } from '../pet/pet.entity';

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
  async findAll(tab?: string) {
    try {
      this.logger.log(`🔍 Fetching posts with tab: ${tab || 'all'}`);

      let where: any = {};

      if (tab === 'vacancy') {
        where.is_vacancy = true;
      } else if (tab === 'urgent') {
        where.is_urgent = true;
        where.is_vacancy = false;
      } else {
        where.is_vacancy = false;
      }

      const posts = await this.postRepo.find({
        where,
        relations: ['user', 'post_media', 'pets'], 
        order: { created_at: 'DESC' },
      });

      this.logger.log(`✅ Successfully fetched ${posts.length} posts`);
      return posts;
    } catch (error) {
      this.logger.error(`❌ Error fetching posts: ${error.message}`);
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
      if (body.petIds) {
        if (Array.isArray(body.petIds)) {
          petIds = body.petIds.map(id => Number(id));
        } else if (typeof body.petIds === 'string') {
          petIds = body.petIds.split(',').map(id => Number(id.trim()));
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
}