// src/comments/comments.service.ts
import { Injectable, NotFoundException } from '@nestjs/common'; // Added NotFoundException just in case
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from './comments.entity';
import { Post } from 'src/posts/posts.entity';
import { User } from 'src/user/user.entity';

@Injectable()
export class CommentsService {
  constructor(
    @InjectRepository(Comment) private commentRepo: Repository<Comment>,
  ) {}

  // 1. Create a Comment
  async create(userId: number, postId: number, content: string): Promise<Comment> {
    const newComment = this.commentRepo.create({
      content,
      user: { id: userId } as User,
      post: { id: postId } as Post,
    });

    const saved = await this.commentRepo.save(newComment);

    // ✅ FIX: Use findOneOrFail
    // This guarantees a return type of 'Comment' (removes null) 
    // because it throws an error if the ID isn't found.
    return this.commentRepo.findOneOrFail({
      where: { id: saved.id },
      relations: ['user'],
    });
  }

  // 2. Get Comments for a Post
  async findByPostId(postId: number): Promise<Comment[]> {
    return this.commentRepo.find({
      where: { post: { id: postId } },
      relations: ['user'],
      order: { created_at: 'ASC' },
    });
  }
}