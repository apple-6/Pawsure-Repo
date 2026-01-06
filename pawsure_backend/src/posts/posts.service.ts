import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';
import { Pet } from '../pet/pet.entity'; // Ensure this path is correct

@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(
    @InjectRepository(Post) private postRepo: Repository<Post>,
    @InjectRepository(PostMedia) private mediaRepo: Repository<PostMedia>,
    @InjectRepository(Pet) private petRepo: Repository<Pet>, // Injected Pet Repository
  ) {}

  /**
   * Fetches posts based on the selected tab.
   * Includes the 'pets' relation to show tags on the frontend.
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
        // Added 'pets' to relations so tags show up in the feed
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
   * Creates a new post or vacancy with multiple pets.
   */
  async create(body: any, files: Express.Multer.File[], userId: number) {
    try {
      this.logger.log(`📝 Creating post for user ${userId}`);

      const isVacancy = body.is_vacancy === 'true' || body.is_vacancy === true;
      const isUrgent = body.is_urgent === 'true' || body.is_urgent === true;

      if (isVacancy && (!body.start_date || !body.end_date)) {
        throw new Error('start_date and end_date are required for vacancy posts');
      }

      // 1. Handle Multiple Pet IDs
      // Multipart-form often sends arrays as a single comma-separated string or multiple entries
      let petIds: number[] = [];
      if (body.petIds) {
        if (Array.isArray(body.petIds)) {
          petIds = body.petIds.map(id => Number(id));
        } else if (typeof body.petIds === 'string') {
          // Handles "1,2,3" string format
          petIds = body.petIds.split(',').map(id => Number(id.trim()));
        }
      }

      // 2. Fetch Pet Entities if IDs exist
      let selectedPets: Pet[] = [];
      if (petIds.length > 0) {
        selectedPets = await this.petRepo.findBy({
          id: In(petIds),
        });
      }

      // 3. Prepare the Post Entity
      const newPost = this.postRepo.create({
        content: body.content,
        is_urgent: isUrgent,
        is_vacancy: isVacancy,
        userId: userId,
        start_date: body.start_date ? new Date(body.start_date) : undefined,
        end_date: body.end_date ? new Date(body.end_date) : undefined,
        pets: selectedPets, // Assigning the array of pet entities
      });

      // 4. Save the post
      const savedPost = await this.postRepo.save(newPost);
      this.logger.log(`✅ Post created with ID: ${savedPost.id}`);

      // 5. Handle media uploads
      if (files && files.length > 0) {
        const mediaRecords = files.map((file) => ({
          media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
          post_id: savedPost.id,
          media_type: file.mimetype.startsWith('image/') ? 'image' : 'video',
        }));
        await this.mediaRepo.save(mediaRecords);
      }

      // 6. Return the post with all relations (including pets)
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