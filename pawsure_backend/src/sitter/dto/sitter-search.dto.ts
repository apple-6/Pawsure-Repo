import { IsOptional, IsString, IsDateString } from 'class-validator';

export class SearchSitterDto {
  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;
}