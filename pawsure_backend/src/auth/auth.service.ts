// src/auth/auth.service.ts

import { Injectable, ConflictException } from '@nestjs/common';
import { UserService } from 'src/user/user.service';
import { RegisterUserDto } from './dto/register-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  // 1. Inject the UserService so you can use its functions
  constructor(
    private readonly userService: UserService,
  ) {}

  // 2. This is the main registration function
  async register(registerUserDto: RegisterUserDto) {
    
    // Check if user's email already exists
    const existingUser = await this.userService.findByEmail(
      registerUserDto.email,
    );
    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(
      registerUserDto.password,
      saltRounds,
    );

    // Create and save the new user
    const newUser = await this.userService.create({
      name: registerUserDto.name,
      email: registerUserDto.email,
      passwordHash: hashedPassword,
    });

    // Return the new user (but hide the password hash)
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, ...result } = newUser;
    return result;
  }
}
