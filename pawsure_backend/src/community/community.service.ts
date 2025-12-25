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

  async findAll(tab: string) {
    const query = this.postRepo.createQueryBuilder('post')
      .leftJoinAndSelect('post.owner', 'owner')
      .leftJoinAndSelect('post.post_media', 'media')
      .select([
        'post', 'media',
        'owner.id', 'owner.name', 'owner.profile_picture'
      ]);

    if (tab === 'urgent') {
      query.where('post.is_urgent = :urgent', { urgent: true });
    }

    return query.orderBy('post.created_at', 'DESC').getMany();
  }

  async create(dto: any, files: Express.Multer.File[], userId: number) {
    // 1. Create the post object
    const postObj = this.postRepo.create({
      content: dto.content,
      location_name: dto.location_name, // Ensure this property exists in post.entity.ts
      userId: userId,
      is_urgent: dto.is_urgent === 'true',
    });

    const savedPost = await this.postRepo.save(postObj);

    if (files && files.length > 0) {
      const mediaRecords = files.map(file => ({
        media_url: `http://localhost:3000/uploads/post-media/${file.filename}`,
        post: savedPost,
        media_type: 'image'
      }));
      await this.mediaRepo.save(mediaRecords);
    }

    return savedPost;
  }
}