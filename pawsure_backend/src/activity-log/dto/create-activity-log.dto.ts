import { IsNotEmpty, IsString, IsInt, IsOptional, IsNumber, IsDateString, IsArray } from 'class-validator';

export class CreateActivityLogDto {
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