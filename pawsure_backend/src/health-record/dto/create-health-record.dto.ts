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
  recordType: HealthRecordType;

  @IsNotEmpty()
  @IsDateString()
  date: string;

  @IsString()
  @IsOptional()
  notes?: string;
}


