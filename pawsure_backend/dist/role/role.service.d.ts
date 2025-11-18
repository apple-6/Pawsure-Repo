import { Repository } from 'typeorm';
import { Role } from './role.entity';
export declare class RoleService {
    private readonly roleRepository;
    constructor(roleRepository: Repository<Role>);
    saveRole(roleName: string): Promise<Role>;
    getAllRoles(): Promise<Role[]>;
}
