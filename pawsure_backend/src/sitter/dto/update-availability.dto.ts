import { IsArray, IsOptional, IsString } from 'class-validator';

export class UpdateAvailabilityDto {
    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    unavailable_dates?: string[];

    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    unavailable_days?: string[];
}