import {
  BadRequestException,
  NotFoundException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  ParseFloatPipe,
  UseInterceptors,
  UploadedFile,
  Post,
  Query,
  Request, 
  Param, 
  Patch, 
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { SitterService } from './sitter.service';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller('sitters')
export class SitterController {
  constructor(private readonly sitterService: SitterService) {}

  @Post('setup')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('idDocumentFile'))
  async create(
    @UploadedFile() file: any,
    @Body() createSitterDto: CreateSitterDto,
    @Request() req,
  ) {
    return await this.sitterService.create(createSitterDto, req.user.id, file);
  }

  @Get()
  async findAll(@Query('minRating') minRating?: string) {
    let parsed: number | undefined;

    if (minRating !== undefined && minRating !== null && minRating.trim() !== '') {
      parsed = Number(minRating);

      if (Number.isNaN(parsed)) {
        throw new BadRequestException('minRating must be a numeric value');
      }
    }

    return await this.sitterService.findAll(parsed);
  }

  @Get('search')
  async searchByAvailability(
    // --- UPDATED: Receive both startDate and endDate as strings ---
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    // 1. Basic validation to ensure both dates are present
    if (!startDate || !endDate) {
      throw new BadRequestException('Both startDate and endDate are required for availability search.');
    }

    // 2. Call the updated service method with both dates
    return await this.sitterService.searchByAvailability(startDate, endDate);
  }

  @Get('my-profile')
  @UseGuards(JwtAuthGuard)
  async getMyProfile(@Request() req) {
    return await this.sitterService.findByUserId(req.user.id);
  }

  @Get('user/:userId')
  async findSitterByUserId(@Param('userId', ParseIntPipe) userId: number) {
    const sitter = await this.sitterService.findByUserId(userId);
    
    // Safety Check: If no sitter profile exists for this user, return 404
    if (!sitter) {
      throw new NotFoundException(`No Sitter Profile found for User ID ${userId}`);
    }

    return sitter;
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