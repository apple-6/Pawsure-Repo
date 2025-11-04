<<<<<<< HEAD
// src/pet/dto/create-pet.dto.ts

import { IsNotEmpty, IsString, IsOptional, IsUrl } from 'class-validator';
=======
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsDateString,
  IsArray,
  Min,
  Max,
} from 'class-validator';
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles

export class CreatePetDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
<<<<<<< HEAD
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
=======
  @IsOptional()
  species?: string;

  @IsString()
  @IsNotEmpty()
  breed: string;

  @IsDateString()
  @IsOptional()
  dob?: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  weight?: number;

  @IsString()
  @IsOptional()
  allergies?: string;

  @IsArray()
  @IsOptional()
  vaccination_dates?: string[];

  @IsDateString()
  @IsOptional()
  last_vet_visit?: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(10)
  mood_rating?: number;

  @IsString()
  @IsOptional()
  photoUrl?: string;

  @IsNumber()
  @IsNotEmpty()
  ownerId: number;
>>>>>>> origin/APPLE-27-Backend-Create-API-endpoints-CRUD-for-Pet-Profiles
}