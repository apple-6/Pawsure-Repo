// src/sitter/dto/sitter-setup.dto.ts

import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsString,
  IsUrl,
  Min,
} from 'class-validator';

export class SitterSetupDto {
  // --- Step 1: Basic Info ---
  @IsString()
  @IsNotEmpty()
  address: string;

  @IsString()
  @IsNotEmpty()
  phoneNumber: string;

  // --- Step 2: Environment ---
  @IsString()
  @IsNotEmpty()
  houseType: string;

  @IsBoolean()
  hasGarden: boolean;

  @IsBoolean()
  hasOtherPets: boolean;

  // --- Step 3: Verification ---
  @IsUrl()
  @IsNotEmpty()
  idDocumentUrl: string; // We expect the frontend to upload this first, then send us the URL

  // --- Step 4: Experience & Rates ---
  @IsString()
  @IsNotEmpty()
  bio: string;

  @IsNumber()
  @Min(0)
  ratePerNight: number;
}
