//pawsure_backend\src\pet\pet.controller.ts
import { 
  Controller, 
  Post,
  Put, // 🆕 ADDED for UPDATE
  Body, 
  UseInterceptors, 
  UploadedFile, 
  Request,
  UseGuards,
  Get,
  Param,
  Delete, 
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PetService } from './pet.service';
import { CreatePetDto } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto'; // 🆕 ADDED
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

// Base route is '/pets'
@Controller('pets')
export class PetController {
  constructor(private readonly petService: PetService) {}

  // ========================================================================
  // READ (GET) ENDPOINTS
  // ========================================================================
  
  // ✅ MAIN ENDPOINT - Get pets for authenticated user
  @Get()
  @UseGuards(JwtAuthGuard)
  async getMyPets(@Request() req) {
    console.log('🔍 JWT User from token:', req.user);
    const userId = req.user.id;
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

  // ========================================================================
  // WRITE (POST) ENDPOINTS
  // ========================================================================
  
  // Create a new pet (Handles photo upload via FileInterceptor)
  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('photo'))
  async createPet(
    @Body() createPetDto: CreatePetDto,
    @UploadedFile() file: any,
    @Request() req,
  ) {
    console.log('➕ Creating pet for user:', req.user.id);
    const ownerId = req.user.id;
    createPetDto.ownerId = ownerId;

    if (file) {
      // ⚠️ IMPORTANT: Replace 'your-supabase-url' with the actual Supabase host!
      createPetDto.photoUrl = `https://YOUR-SUPABASE-URL/storage/photos/${file.filename}`;
    }

    return this.petService.create(createPetDto);
  }

  // ========================================================================
  // 🆕 UPDATE (PUT) ENDPOINT
  // ========================================================================

  /**
   * Updates a pet by ID, ensuring the requesting user is the owner.
   * Route: PUT /pets/:id
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('photo'))
  async updatePet(
    @Param('id') id: string,
    @Body() updatePetDto: UpdatePetDto,
    @UploadedFile() file: any,
    @Request() req,
  ) {
    const petId = Number(id);
    const userId = req.user.id;
    
    console.log(`✏️ Updating Pet ID: ${petId} by User ID: ${userId}`);
    console.log('📤 Update data:', updatePetDto);
    
    // If a new photo is uploaded, update the photoUrl
    if (file) {
      updatePetDto.photoUrl = `https://YOUR-SUPABASE-URL/storage/photos/${file.filename}`;
      console.log('📸 New photo uploaded');
    }
    
    return this.petService.update(petId, updatePetDto, userId);
  }

  // ========================================================================
  // DELETE ENDPOINT
  // ========================================================================

  /**
   * Deletes a pet by ID, ensuring the requesting user is the owner.
   * Route: DELETE /pets/:id
   */
  @Delete(':id') 
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT) 
  async removePet(@Param('id') id: string, @Request() req) {
    const petId = Number(id);
    const userId = req.user.id;
    
    console.log(`🗑️ Deleting Pet ID: ${petId} by User ID: ${userId}`);
    
    await this.petService.remove(petId, userId);
  }
}