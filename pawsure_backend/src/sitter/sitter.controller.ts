import {
  BadRequestException,
  NotFoundException,
  ForbiddenException,
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
  Put,
} from '@nestjs/common';
import { SitterService } from './sitter.service';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { UpdateAvailabilityDto } from './dto/update-availability.dto';

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

  // 🆕 NEW ENDPOINT: Update Sitter Profile by User ID
  @Patch('user/:userId')
  @UseGuards(JwtAuthGuard)
  async updateByUserId(
    @Param('userId', ParseIntPipe) userId: number,
    @Body() updateSitterDto: UpdateSitterDto,
    @Request() req,
  ) {
    // 1. Find the sitter profile belonging to this User ID
    const sitter = await this.sitterService.findByUserId(userId);
    
    if (!sitter) {
      throw new NotFoundException(`No sitter profile found for User ID ${userId}`);
    }

    // 2. Security Check: Ensure the logged-in user matches the target User ID
    // (Optional but recommended)
    if (req.user.id !== userId) {
      throw new ForbiddenException('You can only update your own profile');
    }

    // 3. Call the existing service method using the SITTER'S ID we just found
    return await this.sitterService.update(sitter.id, updateSitterDto, req.user.id);
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

  @Put('availability')
  @UseGuards(JwtAuthGuard) // Assuming you use a guard to get req.user
  async updateAvailability(
    @Request() req,
    @Body() dto: UpdateAvailabilityDto,
  ) {
    // Pass the userId from the auth token and the data from the body
    return this.sitterService.updateAvailability(req.user.id, dto);
  }
}