import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AiService } from '../ai/ai.service';
import { Express } from 'express';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('analyze-photo')
  @UseInterceptors(FileInterceptor('image'))
  async analyzePhoto(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      // Handle error: no file uploaded
    }
    console.log('File received, sending to AI service...');
    return this.aiService.analyzeImage(file.buffer);
  }

  @Get('search')
  async searchByAvailability(@Query('date') date: string) {
    return await this.sitterService.searchByAvailability(date);
  }

  @Get('my-profile')
  @UseGuards(JwtAuthGuard)
  async getMyProfile(@Request() req) {
    return await this.sitterService.findByUserId(req.user.id);
  }


  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return await this.sitterService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSitterDto: UpdateSitterDto,
    @Request() req,
  ) {
    return await this.sitterService.update(id, updateSitterDto, req.user.id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    await this.sitterService.remove(id, req.user.id);
  }
}
