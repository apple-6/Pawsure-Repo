// src/sitter/sitter.controller.ts

import {
  Controller,
  Post,
  Body,
  ValidationPipe,
  UseGuards,
} from '@nestjs/common';
import { SitterService } from './sitter.service';
import { SitterSetupDto } from './dto/sitter-setup.dto';
import { AuthGuard } from '@nestjs/passport'; // 1. Import the AuthGuard
import { GetUser } from 'src/auth/decorators/get-user.decorator'; // 2. Import our custom decorator
import { User } from 'src/user/user.entity';

@Controller('sitter')
@UseGuards(AuthGuard('jwt')) // 3. PROTECT all routes in this controller
export class SitterController {
  constructor(private readonly sitterService: SitterService) {}

  @Post('setup') // Creates the POST /sitter/setup endpoint
  setupProfile(
    @Body(ValidationPipe) setupDto: SitterSetupDto,
    @GetUser() user: User, // 4. Get the logged-in user from the token
  ) {
    // Pass the user's ID and the form data to the service
    return this.sitterService.setupProfile(user.id, setupDto);
  }
}
