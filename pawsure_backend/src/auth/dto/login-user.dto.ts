// src/auth/dto/login-user.dto.ts
import { IsNotEmpty, IsString } from 'class-validator';

export class LoginUserDto {
  @IsString() // <-- It's just a string (could be email or phone)
  @IsNotEmpty()
  identifier: string; // <-- Renamed from 'email'

  @IsString()
  @IsNotEmpty()
  password: string;
}
