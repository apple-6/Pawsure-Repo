// src/comments/comments.controller.ts
import { Controller, Get, Post, Body, Param, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { CommentsService } from './comments.service';
import { AuthGuard } from '@nestjs/passport'; // Assuming you use Passport

@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  // GET /comments/post/:postId
  @Get('post/:postId')
  async getComments(@Param('postId', ParseIntPipe) postId: number) {
    return this.commentsService.findByPostId(postId);
  }

  // POST /comments/post/:postId
  @UseGuards(AuthGuard('jwt')) // Ensure user is logged in
  @Post('post/:postId')
  async createComment(
    @Param('postId', ParseIntPipe) postId: number,
    @Body('content') content: string,
    @Request() req,
  ) {
    // req.user.id comes from the JWT Strategy
    return this.commentsService.create(req.user.id, postId, content);
  }
}