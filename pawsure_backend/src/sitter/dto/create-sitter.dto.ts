import {
  IsString,
  IsOptional,
  IsArray,
  IsNumber,
  IsBoolean,
  IsUrl,
  Min,
} from 'class-validator';

export class CreateSitterDto {
  @IsString()
  @IsOptional()
  bio?: string;

  @IsString()
  @IsOptional()
  experience?: string;

  @IsString()
  @IsOptional()
  photo_gallery?: string;

  @IsArray()
  @IsOptional()
  available_dates?: string[];

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsString()
  @IsOptional()
  houseType?: string;

  @IsBoolean()
  @IsOptional()
  hasGarden?: boolean;

  @IsBoolean()
  @IsOptional()
  hasOtherPets?: boolean;

  @IsUrl()
  @IsOptional()
  idDocumentUrl?: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  ratePerNight?: number;
}
