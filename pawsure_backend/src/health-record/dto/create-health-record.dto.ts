import { IsNotEmpty, IsString, IsDateString, IsEnum, IsOptional } from 'class-validator';

export enum HealthRecordType {
  VACCINATION = 'Vaccination',
  VET_VISIT = 'Vet Visit',
  MEDICATION = 'Medication',
  ALLERGY = 'Allergy',
  NOTE = 'Note',
}

export class CreateHealthRecordDto {
  @IsNotEmpty()
  @IsEnum(HealthRecordType)
  record_type: HealthRecordType;

  @IsNotEmpty()
  @IsDateString()
  record_date: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  clinic?: string;

  @IsDateString()
  @IsOptional()
  nextDueDate?: string;
}


