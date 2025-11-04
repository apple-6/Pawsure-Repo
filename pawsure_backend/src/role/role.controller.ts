import { Controller, Post, Body, Get, BadRequestException } from '@nestjs/common';
import { RoleService } from './role.service';
import { Role } from './role.entity';

@Controller('role')
export class RoleController {
  constructor(private readonly roleService: RoleService) {}

  @Post()
  async createRole(@Body('role') role: string): Promise<{ message: string; data: Role }> {
    if (!role) {
      throw new BadRequestException('Role is required');
    }

    const saved = await this.roleService.saveRole(role);
    return { message: `Role '${role}' saved successfully`, data: saved };
  }

  @Get()
  async getAll(): Promise<{ total: number; data: Role[] }> {
    const roles = await this.roleService.getAllRoles();
    return { total: roles.length, data: roles };
  }
}
