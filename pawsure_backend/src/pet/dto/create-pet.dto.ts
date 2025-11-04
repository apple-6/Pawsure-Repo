// src/pet/dto/create-pet.dto.ts

import { IsNotEmpty, IsString, IsOptional, IsUrl } from 'class-validator';

export class CreatePetDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  breed: string;

  @IsString()
  @IsNotEmpty()
  species: string;

  // This will store the owner's ID, which will likely come from the authenticated user.
  // We'll pass it from the controller, but include it in the DTO for the service layer.
  @IsNotEmpty()
  ownerId: number; 
  
  // The file path or URL will be added by the controller after the file upload.
  @IsString()
  @IsOptional()
  dob: Date;
  @IsUrl() // Assuming the service stores a URL (e.g., Supabase storage URL)
  photoUrl?: string; 
}