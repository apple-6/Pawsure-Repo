import { IsString, IsNotEmpty } from 'class-validator';

export class CreateMealLogDto {
  @IsString()
  @IsNotEmpty()
  meal_type: string;
}
