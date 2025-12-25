import { Controller, Post, Get, Body, UseGuards, UseInterceptors, UploadedFiles, Query } from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { CommunityService } from '../community/community.service';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Get()
  findAll(@Query('tab') tab: string) {
    return this.communityService.findAll(tab);
  }

  @Post('create')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FilesInterceptor('media', 10, {
    storage: diskStorage({
      destination: './uploads/post-media',
      filename: (req, file, cb) => {
        const randomName = Array(32)
          .fill(null)
          .map(() => (Math.round(Math.random() * 16)).toString(16))
          .join('');
        return cb(null, `${randomName}${extname(file.originalname)}`);
      },
    }),
  }))
  async createPost(
    @Body() body: any,
    @UploadedFiles() files: Express.Multer.File[] | undefined,
    @GetUser() user: any,
  ) {
    const uploadedFiles = files && files.length > 0 ? files : [];
    return this.communityService.create(body, uploadedFiles, user.id);
  }
}