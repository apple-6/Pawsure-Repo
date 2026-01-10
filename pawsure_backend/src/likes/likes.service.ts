import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Like } from './likes.entity';

@Injectable()
export class LikesService {
  constructor(
    @InjectRepository(Like)
    private likesRepository: Repository<Like>,
  ) {}

  async toggleLike(userId: number, postId: number): Promise<{ isLiked: boolean; likesCount: number }> {
    // Check if like exists
    const existingLike = await this.likesRepository.findOne({
      where: {
        user: { id: userId },
        post: { id: postId },
      },
    });

    if (existingLike) {
      // Unlike
      await this.likesRepository.remove(existingLike);
    } else {
      // Like
      const newLike = this.likesRepository.create({
        user: { id: userId },
        post: { id: postId },
      });
      await this.likesRepository.save(newLike);
    }

    // Get updated count
    const likesCount = await this.likesRepository.count({
      where: { post: { id: postId } },
    });

    return { isLiked: !existingLike, likesCount };
  }
}