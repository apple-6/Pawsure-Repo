import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Request,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { SitterService } from './sitter.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { Express } from 'express';

@Controller('sitters')
export class SitterController {
  constructor(private readonly sitterService: SitterService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('idDocument'))
  async create(
    @Body() createSitterDto: CreateSitterDto,
    @Request() req,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return await this.sitterService.create(createSitterDto, req.user.id, file);
  }

  @Get()
  async findAll() {
    return await this.sitterService.findAll();
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
