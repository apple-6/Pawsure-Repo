// src/pet/pet.controller.ts

import { 
  Controller, 
  Post, 
  Body, 
  UseInterceptors, 
  UploadedFile, 
  Request,
  UseGuards,
  Get,
  Param,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PetService } from './pet.service';
import { CreatePetDto } from './dto/create-pet.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('pets')
export class PetController {
  constructor(private readonly petService: PetService) {}

  // ✅ MAIN ENDPOINT - Get pets for authenticated user
  @Get()
  @UseGuards(JwtAuthGuard)
  async getMyPets(@Request() req) {
    console.log('🔍 JWT User from token:', req.user);
    const userId = req.user.id; // Changed from req.user.sub to req.user.id
    console.log('🔍 Fetching pets for user ID:', userId);
    
    const pets = await this.petService.findByOwner(userId);
    console.log('📦 Found', pets.length, 'pets for user', userId);
    
    return pets;
  }

  // 🐛 DEBUG ENDPOINT - See all pets (NO AUTH REQUIRED)
  @Get('debug')
  async debugAllPets() {
    console.log('🐛 Debug endpoint called - fetching all pets');
    const allPets = await this.petService.findAll();
    console.log('🐛 Total pets in database:', allPets.length);
    return { 
      total: allPets.length, 
      pets: allPets.map(p => ({ 
        id: p.id, 
        name: p.name, 
        ownerId: p.ownerId,
        species: p.species,
        breed: p.breed
      }))
    };
  }

  // Get pets by owner ID (for testing/admin)
  @Get('owner/:ownerId')
  async getPetsByOwnerParam(@Param('ownerId') ownerId: string) {
    console.log('🔍 Fetching pets for ownerId:', ownerId);
    return this.petService.findByOwner(Number(ownerId));
  }

  // Create a new pet
  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('photo'))
  async createPet(
    @Body() createPetDto: CreatePetDto,
    @UploadedFile() file: any,
    @Request() req,
  ) {
    console.log('➕ Creating pet for user:', req.user.id);
    const ownerId = req.user.id; // Changed from req.user?.id || 1
    createPetDto.ownerId = ownerId;

    if (file) {
      createPetDto.photoUrl = `https://your-supabase-url/storage/photos/${file.filename}`;
    }

    return this.petService.create(createPetDto);
  }
}