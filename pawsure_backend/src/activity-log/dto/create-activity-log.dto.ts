import { IsNotEmpty, IsString, IsInt, IsOptional, IsNumber, IsDateString, IsArray, ArrayMinSize } from 'class-validator';

export class CreateActivityLogDto {
  // ✅ NEW: Accept array of pet IDs instead of single petId in route
  @IsNotEmpty()
  @IsArray()
  @ArrayMinSize(1, { message: 'At least one pet must be selected' })
  @IsInt({ each: true, message: 'Each pet ID must be a valid integer' })
  pet_ids: number[];

  @IsNotEmpty()
  @IsString()
  activity_type: string;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsInt()
  duration_minutes: number;

  @IsOptional()
  @IsNumber()
  distance_km?: number;

  @IsOptional()
  @IsInt()
  calories_burned?: number;

  @IsNotEmpty()
  @IsDateString()
  activity_date: string;

  @IsOptional()
  @IsArray()
  route_data?: Array<{ lat: number; lng: number; timestamp: string }>;
}