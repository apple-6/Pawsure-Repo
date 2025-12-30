// pawsure_backend\src\pet\pet.controller.ts
import { 
  Controller, 
  Post,
  Put,
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
import { UpdatePetDto } from './dto/update-pet.dto'; 
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FileService } from '../file/file.service'; // 🆕 Imported from Sitter logic
import { Express } from 'express';

@Controller('pets')
export class PetController {
  constructor(
    private readonly petService: PetService,
    private readonly fileService: FileService, // 🆕 Injected FileService
  ) {}

  // ========================================================================
  // READ (GET) ENDPOINTS
  // ========================================================================
  
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

  @Get('owner/:ownerId')
  async getPetsByOwnerParam(@Param('ownerId') ownerId: string) {
    console.log('🔍 Fetching pets for ownerId:', ownerId);
    return this.petService.findByOwner(Number(ownerId));
  }

  // ========================================================================
  // WRITE (POST) ENDPOINTS
  // ========================================================================
  
  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('photo'))
  async createPet(
    @Body() createPetDto: CreatePetDto,
    @UploadedFile() file: Express.Multer.File, // 🆕 Use Express.Multer.File type
    @Request() req,
  ) {
    console.log('➕ Creating pet for user:', req.user.id);
    const ownerId = req.user.id;
    createPetDto.ownerId = ownerId;

    // --- UPDATED PHOTO LOGIC ---
    if (file) {
      // Logic from SitterService: Upload buffer to storage and get public URL
      const photoUrl = await this.fileService.uploadPublicFile(
        file.buffer, 
        file.originalname, 
        'pet-photos'
      );
      createPetDto.photoUrl = photoUrl;
      console.log('📸 Photo uploaded and URL assigned:', photoUrl);
    }

    return this.petService.create(createPetDto);
  }

  // ========================================================================
  // UPDATE (PUT) ENDPOINT
  // ========================================================================

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('photo'))
  async updatePet(
    @Param('id') id: string,
    @Body() updatePetDto: UpdatePetDto,
    @UploadedFile() file: Express.Multer.File, // 🆕 Use Express.Multer.File type
    @Request() req,
  ) {
    const petId = Number(id);
    const userId = req.user.id;
    
    console.log(`✏️ Updating Pet ID: ${petId} by User ID: ${userId}`);
    
    // --- UPDATED PHOTO LOGIC ---
    if (file) {
      // Replace manual URL building with the dynamic FileService upload
      const photoUrl = await this.fileService.uploadPublicFile(
        file.buffer, 
        file.originalname, 
        'pet-photos'
      );
      updatePetDto.photoUrl = photoUrl;
      console.log('📸 New photo uploaded and URL assigned:', photoUrl);
    }
    
    return this.petService.update(petId, updatePetDto, userId);
  }

  // ========================================================================
  // DELETE ENDPOINT
  // ========================================================================

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