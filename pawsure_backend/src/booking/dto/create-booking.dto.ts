import { IsNotEmpty, IsNumber, IsDateString, IsOptional, IsString } from 'class-validator';

export class CreateBookingDto {
  @IsNotEmpty()
  @IsDateString()
  start_date: string;

  @IsNotEmpty()
  @IsDateString()
  end_date: string;

  @IsNotEmpty()
  @IsNumber()
  total_amount: number;

  @IsNotEmpty()
  @IsNumber()
  sitterId: number;

  @IsNotEmpty()
  @IsNumber()
  petId: number;

  @IsNotEmpty() 
  @IsString()
  drop_off_time: string;

  @IsNotEmpty() 
  @IsString()
  pick_up_time: string;

  @IsOptional()
  @IsString()
  message?: string;

  @IsOptional()
  @IsNumber()
  payment_method_id?: number;

}