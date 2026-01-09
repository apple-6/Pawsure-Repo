import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  Query,
  BadRequestException,
  Request,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { PostsService } from './posts.service';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  /*@Get()
  async findAll(@Query('tab') tab?: string) {
    try {
      return await this.postsService.findAll(tab);
    } catch (error) {
      throw new BadRequestException(`Failed to fetch posts: ${error.message}`);
    }
  }*/

  @Get()
  @UseGuards(JwtAuthGuard)
async findAll(@Request() req,@Query('tab') tab?: string ) {
  console.log('🚀 GET /posts called with tab:', tab);
  const userId = req.user?.id; 
    console.log('👤 Fetching for User ID:', userId);
  try {
    const posts = await this.postsService.findAll(tab, userId);
    console.log('✅ Posts service returned:', posts.length, 'posts');
    return posts;
  } catch (error) {
    console.log('❌ Posts service error:', error.message);
    throw new BadRequestException(`Failed to fetch posts: ${error.message}`);
  }
}

  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FilesInterceptor('media', 10, {
      storage: diskStorage({
        destination: './uploads/post-media',
        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
        },
      }),
      fileFilter: (req, file, cb) => {
        const allowedMimes = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'video/mp4',
          'video/quicktime',
          'video/x-msvideo',
        ];
        if (allowedMimes.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(
            new BadRequestException(
              `File type not allowed: ${file.mimetype}`,
            ),
            false,
          );
        }
      },
    }),
  )
  async create(
    @Body() body: any,
    @UploadedFiles() files: Express.Multer.File[] | undefined,
    @GetUser() user: any,
  ) {
    // Validate user
    if (!user || !user.id) {
      throw new BadRequestException('User not authenticated');
    }

    // Validate content
    if (!body.content || body.content.trim() === '') {
      throw new BadRequestException('Post content is required');
    }

    // Handle optional files
    const uploadedFiles = files && files.length > 0 ? files : [];

    try {
      const post = await this.postsService.create(body, uploadedFiles, user.id);
      return {
        success: true,
        message: 'Post created successfully',
        data: post,
      };
    } catch (error) {
      throw new BadRequestException(`Failed to create post: ${error.message}`);
    }
  }
  
}