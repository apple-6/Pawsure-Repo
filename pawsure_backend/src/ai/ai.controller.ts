import { Controller, Post, Body, Param, UploadedFile, UseInterceptors, Get } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AiService } from './ai.service';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('scan')
  @UseInterceptors(FileInterceptor('image'))
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    return await this.aiService.classify(file.buffer);
  }

  @Post('save/:petId')
  async saveResult(
    @Param('petId') petId: number,
    @Body() data: { result: string; confidence: string }
  ) {
    return await this.aiService.saveScan(petId, data.result, data.confidence);
  }

  @Get('history/:petId')
  async getHistory(@Param('petId') petId: number) {
    return await this.aiService.getScanHistory(petId);
  }
}