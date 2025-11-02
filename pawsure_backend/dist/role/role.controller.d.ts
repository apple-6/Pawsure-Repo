import { RoleService } from './role.service';
import { Role } from './role.entity';
export declare class RoleController {
    private readonly roleService;
    constructor(roleService: RoleService);
    createRole(role: string): Promise<{
        message: string;
        data: Role;
    }>;
    getAll(): Promise<{
        total: number;
        data: Role[];
    }>;
}
