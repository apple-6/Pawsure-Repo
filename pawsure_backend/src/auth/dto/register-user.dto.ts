// src/auth/dto/register-user.dto.ts

import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  IsOptional, // <-- You were missing this
  ValidateIf, // <-- You were missing this
} from 'class-validator';

export class RegisterUserDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  // --- THIS IS THE CORRECTED EMAIL FIELD ---
  @IsEmail()
  @IsOptional() // 1. It's optional in general
  @ValidateIf((o) => !o.phone_number) // 2. But...
  @IsNotEmpty({ message: 'Email or phone number must be provided.' }) // 3. ...it's NOT empty if phone_number is missing
  email?: string; // Use '?' to mark as optional in TypeScript

  // --- THIS IS THE CORRECTED PHONE FIELD ---
  @IsString()
  @IsOptional() // 1. It's optional in general
  @ValidateIf((o) => !o.email) // 2. But...
  @IsNotEmpty({ message: 'Email or phone number must be provided.' }) // 3. ...it's NOT empty if email is missing
  phone_number?: string; // Use '?' to mark as optional in TypeScript

  // --- YOUR PASSWORD FIELD WAS PERFECT ---
  @IsNotEmpty()
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  // --- ROLE FIELD ---
  @IsString()
  @IsOptional()
  role?: string; // Optional, defaults to 'user' in entity
}
