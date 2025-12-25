import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './posts.entity';
import { PostMedia } from './post-media.entity';

@Injectable()
export class PostsService {
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
    // 1. Create the post object
    // Note: Ensure these property names match your post.entity.ts exactly
    const postData = this.postRepo.create({
      content: body.content,
      is_urgent: body.is_urgent === 'true',
      userId: userId,
    });
  
    // 2. Save the post and ensure we capture the single result
    const savedPost: Post = await this.postRepo.save(postData);
  
    // 3. Handle media uploads
    if (files && files.length > 0) {
      const mediaRecords = files.map(file => ({
        media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
        post: savedPost, // Now explicitly a single Post object
        media_type: 'image',
      }));
  
      await this.mediaRepo.save(mediaRecords);
    }
  
    return savedPost;
  }
}