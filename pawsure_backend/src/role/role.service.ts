import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Role } from './role.entity';

@Injectable()
export class RoleService {
  constructor(
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
  ) {}

  async saveRole(roleName: string): Promise<Role> {
    const role = this.roleRepository.create({ name: roleName });
    return await this.roleRepository.save(role);
  }

  async getAllRoles(): Promise<Role[]> {
    return await this.roleRepository.find();
  }
}
