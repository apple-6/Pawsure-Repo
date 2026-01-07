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

  @Get()
  async findAll(@Query('tab') tab?: string) {
    console.log('🚀 GET /posts called with tab:', tab);
    try {
      const posts = await this.postsService.findAll(tab);
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
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
        },
      }),
      fileFilter: (req, file, cb) => {
        const allowedMimes = [
          'image/jpeg', 'image/png', 'image/gif', 'image/webp',
          'video/mp4', 'video/quicktime', 'video/x-msvideo',
        ];
        if (allowedMimes.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(new BadRequestException(`File type not allowed: ${file.mimetype}`), false);
        }
      },
    }),
  )
  async create(
    @Body() body: any,
    @UploadedFiles() files: Express.Multer.File[] | undefined,
    @GetUser() user: any,
  ) {
    if (!user || !user.id) {
      throw new BadRequestException('User not authenticated');
    }

    if (!body.content || body.content.trim() === '') {
      throw new BadRequestException('Post content is required');
    }

    // --- TRANSFORM DATA FROM FLUTTER ---
    // Handle Boolean conversion (Form-data often sends strings)
    const isVacancy = body.is_vacancy === 'true' || body.is_vacancy === true;
    
    // Convert rate to number if it exists
    const rate = body.rate_per_night ? parseFloat(body.rate_per_night) : null;

    // Ensure petIds is handled as an array (Flutter sends array, but check if it's JSON stringified)
    let petIds = body.petIds;
    if (typeof petIds === 'string') {
      try { petIds = JSON.parse(petIds); } catch (e) { petIds = [petIds]; }
    }

    const uploadedFiles = files && files.length > 0 ? files : [];

    try {
      // Pass the cleaned data to the service
      const postData = {
        ...body,
        is_vacancy: isVacancy,
        rate_per_night: rate,
        petIds: petIds,
      };

      const post = await this.postsService.create(postData, uploadedFiles, user.id);
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