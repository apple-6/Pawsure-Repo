//pawsure_backend\src\health-record\dto\update-health-record.dto.ts
import { IsString, IsDateString, IsOptional } from 'class-validator';

export class UpdateHealthRecordDto {
  @IsOptional()
  @IsString()
  record_type?: string;

  @IsOptional()
  @IsDateString()
  record_date?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  clinic?: string;

  @IsOptional()
  @IsDateString()
  nextDueDate?: string;
}