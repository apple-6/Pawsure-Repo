// src/auth/auth.controller.ts

import { Controller, Post, Body, ValidationPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';

@Controller('auth') // All routes in this file will start with /auth
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register') // Creates the POST /auth/register endpoint
  register(@Body(ValidationPipe) registerUserDto: RegisterUserDto) {
    // It takes the request body, validates it using the DTO,
    // and passes it to the authService.register function
    return this.authService.register(registerUserDto);
  }

  @Post('login') // <-- Make sure this is here
  login(@Body(ValidationPipe) loginUserDto: LoginUserDto) {
    return this.authService.login(loginUserDto);
  }
}
