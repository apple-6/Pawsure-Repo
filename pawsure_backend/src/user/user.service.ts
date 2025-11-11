import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
// Import your DTO, e.g., CreateUserDto, if you use it in the create method
// import { CreateUserDto } from './dto/create-user.dto'; 

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  // --- 1. ADD THIS FUNCTION ---
  /**
   * Finds a user by their phone number.
   */
  async findByPhone(phone: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { phone_number: phone } });
  }

  // --- 2. ADD THIS FUNCTION ---
  /**
   * Finds a user by EITHER email OR phone number.
   * Used for the login process.
   */
  async findOneByIdentifier(identifier: string): Promise<User | null> {
    return this.usersRepository.findOne({
      where: [
        { email: identifier }, 
        { phone_number: identifier }
      ],
    });
  }

  /**
   * Creates and saves a new user.
   * Assumes password hash is already created.
   * The 'Partial<User>' type will correctly accept your
   * { name, email, phone_number, passwordHash } object.
   */
  async create(userData: Partial<User>): Promise<User> {
    const newUser = this.usersRepository.create(userData);
    return this.usersRepository.save(newUser);
  }

  /**
   * Finds a user by their ID.
   */
  async findById(id: number) {
    return this.usersRepository.findOne({ where: { id } });
  }

  /**
   * Updates a user's role.
   */
  async updateUserRole(id: number, newRole: string) {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    user.role = newRole;
    return this.usersRepository.save(user);
  }
}
