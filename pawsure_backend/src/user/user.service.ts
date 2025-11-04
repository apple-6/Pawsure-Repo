// src/user/user.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm'; // <-- 1. Add this import
import { Repository } from 'typeorm'; // <-- 2. Add this import
import { User } from './user.entity'; // <-- 3. Add this import

@Injectable()
export class UserService {
  // 4. Add this constructor to inject the User repository
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // 5. Add this function
  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  // 6. Add this function
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
