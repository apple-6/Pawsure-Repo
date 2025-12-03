import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { SitterService } from './sitter.service';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { SearchSitterDto } from './dto/sitter-search.dto';
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

  /**
   * Search for sitters by location and/or date availability
   * @example
   * /sitters/search?location=New York
   * /sitters/search?startDate=2025-12-20&endDate=2025-12-25
   * /sitters/search?location=New York&startDate=2025-12-20&endDate=2025-12-25
   */
  @Get('search')
  async searchSitters(@Query() searchSitterDto: SearchSitterDto) {
    // The DTO will automatically validate the query parameters
    return await this.sitterService.searchSitters(searchSitterDto);
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
