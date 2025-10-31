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