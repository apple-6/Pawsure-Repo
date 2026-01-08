import { Controller, Post, Body, Param, UploadedFile, UseInterceptors, Get, Delete, ParseIntPipe } from '@nestjs/common';
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
    @Param('petId', ParseIntPipe) petId: number,
    @Body() data: { result: string; confidence: string }
  ) {
    return await this.aiService.saveScan(petId, data.result, data.confidence);
  }

  @Get('history/:petId')
  async getHistory(@Param('petId') petId: number) {
    return await this.aiService.getScanHistory(petId);
  }

  // Correct way
  @Delete('scan/:id') 
  async removeScan(@Param('id', ParseIntPipe) id: number) {
    await this.aiService.deleteScan(id);
    return { message: 'Deleted successfully' };
  }
}