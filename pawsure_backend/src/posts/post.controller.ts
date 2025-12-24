import { Controller, Post, Get, Body, UseGuards, UseInterceptors, UploadedFiles, Query } from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { PostsService } from './posts.service';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Get()
  findAll(@Query('tab') tab: string) {
    return this.postsService.findAll(tab);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FilesInterceptor('media', 10, {
    storage: diskStorage({
      destination: './uploads/post-media',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
      },
    }),
  }))
  create(
    @Body() body: any,
    @UploadedFiles() files: Express.Multer.File[],
    @GetUser() user: any,
  ) {
    return this.postsService.create(body, files, user.id);
  }
}