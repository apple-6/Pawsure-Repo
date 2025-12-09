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
}