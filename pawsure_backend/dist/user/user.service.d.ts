import { Repository } from 'typeorm';
import { User } from './user.entity';
export declare class UserService {
    private usersRepository;
    constructor(usersRepository: Repository<User>);
    findByEmail(email: string): Promise<User | null>;
    findByPhone(phone: string): Promise<User | null>;
    findOneByIdentifier(identifier: string): Promise<User | null>;
    create(userData: Partial<User>): Promise<User>;
    findById(id: number): Promise<User | null>;
    updateUserRole(id: number, newRole: string): Promise<User>;
}
