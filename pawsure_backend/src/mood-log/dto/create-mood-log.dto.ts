import { IsInt, IsString, IsOptional, Min, Max } from 'class-validator';

export class CreateMoodLogDto {
  @IsInt()
  @Min(1)
  @Max(10)
  mood_score: number;

  @IsString()
  @IsOptional()
  mood_label?: string;

  @IsString()
  @IsOptional()
  notes?: string;
}

