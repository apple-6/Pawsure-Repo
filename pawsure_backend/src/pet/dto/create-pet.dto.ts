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

  @IsNumber()
  @IsNotEmpty()
  ownerId: number;
}