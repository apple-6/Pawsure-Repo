//pawsure_backend\src\pet\dto\create-pet.dto.ts
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsDateString,
  IsArray,
  Min,
  Max,
  IsIn,
} from 'class-validator';

export class CreatePetDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
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

  @IsString()
@IsOptional()
@IsIn(['sterilized', 'not_sterilized', 'unknown'])
sterilization_status?: string;

  @IsNumber()
  @IsNotEmpty()
  ownerId: number;
}