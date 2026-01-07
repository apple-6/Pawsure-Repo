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

  @IsNumber()
  @IsOptional()
  @Min(0)
  height?: number;

  @IsNumber()
  @IsOptional()
  @Min(1)
  @Max(5)
  body_condition_score?: number;

  @IsArray()
  @IsOptional()
  weight_history?: { date: string; weight: number }[];

  @IsString()
  @IsOptional()
  allergies?: string;

  @IsString()
  @IsOptional()
  food_brand?: string;

  @IsString()
  @IsOptional()
  daily_food_amount?: string;

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