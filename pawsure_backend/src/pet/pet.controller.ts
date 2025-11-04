<<<<<<< HEAD
// src/pet/pet.controller.ts

import { 
    Controller, 
    Post, 
    Body, 
    UseInterceptors, 
    UploadedFile, 
    Request,
    UseGuards, // Assuming you have an authentication guard
    Get,
    Param,
    Query
  } from '@nestjs/common';
  import { FileInterceptor } from '@nestjs/platform-express'; // Make sure this package is installed
  import { PetService } from './pet.service';
  import { CreatePetDto } from './dto/create-pet.dto';
  // import { AuthGuard } from '../auth/auth.guard'; // Import your auth guard
  
  @Controller('pets')
  export class PetController {
    constructor(private readonly petService: PetService) {}
  
    @Post()
    // @UseGuards(AuthGuard) // Protect the route with an authentication guard
    @UseInterceptors(FileInterceptor('photo')) // 'photo' is the field name from the form-data
    async createPet(
      @Body() createPetDto: CreatePetDto,
      @UploadedFile() file: Express.Multer.File,
      @Request() req, // Used to get user info after authentication
    ) {
      // 1. **Authentication and Owner ID**: Get the owner's ID from the authenticated request object.
      // For demonstration, let's assume the user object is attached to 'req.user' after authentication.
      const ownerId = req.user?.id || 1; // Replace '1' with actual logic (e.g., req.user.id)
      createPetDto.ownerId = ownerId;
  
      // 2. **Handle Photo Upload**: Get the URL/path where the photo was saved.
      // In a real application, you'd upload 'file' to Supabase Storage here and get the public URL.
      if (file) {
        // **Placeholder for actual file upload logic to Supabase Storage**
        // For now, let's assume a function that returns a URL.
        // E.g., const photoUrl = await this.petService.uploadPhoto(file);
        createPetDto.photoUrl = `https://your-supabase-url/storage/photos/${file.filename}`; // Placeholder
      }
  
      // 3. **Create Pet Profile**
      return this.petService.createPet(createPetDto);
    }

    @Get('owner/:ownerId')
    async getPetsByOwnerParam(@Param('ownerId') ownerId: string) {
      return this.petService.findPetsByOwner(Number(ownerId));
    }

    @Get()
    async getPetsByOwnerQuery(@Query('ownerId') ownerId?: string) {
      if (!ownerId) return [];
      return this.petService.findPetsByOwner(Number(ownerId));
    }
  }
=======
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
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
