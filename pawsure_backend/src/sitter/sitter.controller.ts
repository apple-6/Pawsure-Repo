import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  Query,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
  ParseFloatPipe,
} from '@nestjs/common';
import { SitterService } from './sitter.service';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('sitters')
export class SitterController {
  constructor(private readonly sitterService: SitterService) {}

  @Post('setup')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createSitterDto: CreateSitterDto, @Request() req) {
    return await this.sitterService.create(createSitterDto, req.user.id);
  }

  @Get()
  async findAll(@Query('minRating', ParseFloatPipe) minRating?: number) {
    return await this.sitterService.findAll(minRating);
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