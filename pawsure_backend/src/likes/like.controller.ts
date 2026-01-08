import { Controller, Post, Param, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { LikesService } from './likes.service';
// Assuming you have a JwtAuthGuard
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('likes')
export class LikesController {
  constructor(private readonly likesService: LikesService) {}

  @UseGuards(JwtAuthGuard)
  @Post(':postId')
  async toggleLike(@Request() req, @Param('postId', ParseIntPipe) postId: number) {
    return this.likesService.toggleLike(req.user.id, postId);
  }
}