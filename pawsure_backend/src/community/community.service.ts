import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../posts/posts.entity';
import { PostMedia } from '../posts/post-media.entity';

@Injectable()
export class CommunityService {
  constructor(
    @InjectRepository(Post) private postRepo: Repository<Post>,
    @InjectRepository(PostMedia) private mediaRepo: Repository<PostMedia>,
  ) {}

  async findAll(tab?: string) {
    const query = this.postRepo.createQueryBuilder('post')
      .leftJoinAndSelect('post.user', 'user')
      .leftJoinAndSelect('post.post_media', 'media');

    if (tab === 'urgent') {
      query.where('post.is_urgent = :urgent', { urgent: true });
    }

    return query.orderBy('post.created_at', 'DESC').getMany();
  }

  async create(body: any, files: Express.Multer.File[], userId: number) {
    try {
      // Parse is_urgent from string to boolean
      const isUrgent = typeof body.is_urgent === 'string' 
        ? body.is_urgent === 'true' 
        : Boolean(body.is_urgent);

      // Create post - DO NOT include location_name
      const savedPost = await this.postRepo.save({
        content: body.content || '',
        is_urgent: isUrgent,
        userId: userId,
      });

      // Handle media uploads
      if (files && files.length > 0) {
        const mediaRecords = files.map((file) => {
          const media = new PostMedia();
          media.media_url = `http://localhost:3000/uploads/post-media/${file.filename}`;
          media.media_type = file.mimetype.startsWith('video') ? 'video' : 'image';
          media.post = savedPost;
          return media;
        });

        await this.mediaRepo.save(mediaRecords);
      }

      // Return post with relations loaded
      return this.postRepo.findOne({
        where: { id: savedPost.id },
        relations: ['user', 'post_media'],
      });
    } catch (error) {
      console.error('Error creating post:', error);
      throw new Error(`Failed to create post: ${error.message}`);
    }
  }
}