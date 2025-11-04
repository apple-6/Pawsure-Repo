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
} from '@nestjs/common';
import { PetService } from './pet.service';
import { CreatePetDto } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('pets')
@UseGuards(JwtAuthGuard)
export class PetController {
  constructor(private readonly petService: PetService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createPetDto: CreatePetDto, @Request() req) {
    // Ensure the ownerId matches the authenticated user
    createPetDto.ownerId = req.user.id; // Changed from req.user.userId to req.user.id
    return await this.petService.create(createPetDto);
  }

  @Get()
  async findAll(@Query('ownerId', ParseIntPipe) ownerId?: number) {
    return await this.petService.findAll(ownerId);
  }

  @Get('my-pets')
  async findMyPets(@Request() req) {
    return await this.petService.findByOwner(req.user.id); // Changed from req.user.userId to req.user.id
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return await this.petService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePetDto: UpdatePetDto,
    @Request() req,
  ) {
    return await this.petService.update(id, updatePetDto, req.user.id); // Changed from req.user.userId to req.user.id
  }

  @Patch(':id/streak')
  async updateStreak(
    @Param('id', ParseIntPipe) id: number,
    @Body('streak') streak: number,
    @Request() req,
  ) {
    // Verify ownership before updating
    const pet = await this.petService.findOne(id);
    if (pet.ownerId !== req.user.id) { // Changed from req.user.userId to req.user.id
      throw new Error('Unauthorized');
    }
    return await this.petService.updateStreak(id, streak);
  }

  @Patch(':id/mood')
  async updateMoodRating(
    @Param('id', ParseIntPipe) id: number,
    @Body('mood_rating') moodRating: number,
    @Request() req,
  ) {
    // Verify ownership before updating
    const pet = await this.petService.findOne(id);
    if (pet.ownerId !== req.user.id) { // Changed from req.user.userId to req.user.id
      throw new Error('Unauthorized');
    }
    return await this.petService.updateMoodRating(id, moodRating);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    await this.petService.remove(id, req.user.id); // Changed from req.user.userId to req.user.id
  }
}