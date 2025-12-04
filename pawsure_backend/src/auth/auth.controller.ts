// src/auth/auth.controller.ts

import { Controller, Post, Get, Body, ValidationPipe, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth') // All routes in this file will start with /auth
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register') // Creates the POST /auth/register endpoint
  register(@Body(ValidationPipe) registerUserDto: RegisterUserDto) {
    // It takes the request body, validates it using the DTO,
    // and passes it to the authService.register function
    return this.authService.register(registerUserDto);
  }

  @Post('login') // POST /auth/login endpoint
  login(@Body(ValidationPipe) loginUserDto: LoginUserDto) {
    return this.authService.login(loginUserDto);
  }

  // 🆕 NEW: GET /auth/profile endpoint
  @Get('profile')
  @UseGuards(JwtAuthGuard) // Requires valid JWT token
  getProfile(@Request() req) {
    console.log('🔍 GET /auth/profile - User from JWT:', req.user);
    
    // req.user comes from JWT strategy validation
    // It contains the full user object from your database
    return {
      id: req.user.id,
      name: req.user.name,
      email: req.user.email,
      role: req.user.role,
      phone_number: req.user.phone_number,
      profile_picture: req.user.profile_picture,
    };
  }
}