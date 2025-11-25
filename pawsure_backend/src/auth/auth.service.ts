import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { UserService } from 'src/user/user.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  // --- REGISTER FUNCTION ---
  async register(registerUserDto: RegisterUserDto) {
    const { email, phone_number, password, name } = registerUserDto;

    // --- CHANGED: Conflict Checking ---
    // 1. Check if email is already in use (if provided)
    if (email) {
      const existingUser = await this.userService.findByEmail(email);
      if (existingUser) {
        throw new ConflictException('Email already in use');
      }
    }

    // 2. Check if phone number is in use (if provided)
    // NOTE: This assumes 'findByPhone' exists in UserService
    if (phone_number) {
      const existingUser = await this.userService.findByPhone(phone_number);
      if (existingUser) {
        throw new ConflictException('Phone number already in use');
      }
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // --- CHANGED: User Creation ---
    // Pass the new phone_number field to your create service
    // NOTE: This assumes 'create' in UserService accepts this
    const newUser = await this.userService.create({
      name: name,
      email: email,
      phone_number: phone_number, // <-- ADDED
      passwordHash: hashedPassword,
    });

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, ...result } = newUser;
    return result;
  }

  // --- LOGIN FUNCTION ---
  async login(loginUserDto: LoginUserDto) {
    // --- CHANGED: Use 'identifier' from DTO ---
    // NOTE: This assumes 'findOneByIdentifier' exists in UserService
    const user = await this.userService.findOneByIdentifier(
      loginUserDto.identifier, // <-- CHANGED from loginUserDto.email
    );

    if (!user) {
      // --- CHANGED: Generic error message ---
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordMatching = await bcrypt.compare(
      loginUserDto.password,
      user.passwordHash,
    );

    if (!isPasswordMatching) {
      // --- CHANGED: Generic error message ---
      throw new UnauthorizedException('Invalid credentials');
    }

    // --- CHANGED: More complete JWT payload ---
    const payload = {
      sub: user.id, // 'sub' (subject) is the standard for user ID
      email: user.email, // Can be null, which is fine
      phone_number: user.phone_number, // Can be null, which is fine
      role: user.role,
    };

    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
