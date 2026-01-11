import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, IsDateString, IsArray } from 'class-validator';
import { EventType, EventStatus } from '../entities/event.entity';

export class CreateEventDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsDateString()
  @IsNotEmpty()
  dateTime: string;

  @IsEnum(EventType)
  eventType: EventType;

  @IsEnum(EventStatus)
  @IsOptional()
  status?: EventStatus;

  @IsString()
  @IsOptional()
  location?: string;

  @IsString()
  @IsOptional()
  notes?: string;

  // ✅ OPTION 1: Single Pet
  @IsNumber()
  @IsOptional()
  petId?: number;

  // ✅ OPTION 2: Multiple Pets (New UI sends this)
  @IsArray()
  @IsOptional()
  pet_ids?: number[];
}