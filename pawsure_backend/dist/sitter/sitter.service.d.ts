import { Sitter } from './sitter.entity';
import { Repository } from 'typeorm';
import { SitterSetupDto } from './dto/sitter-setup.dto';
import { UserService } from 'src/user/user.service';
export declare class SitterService {
    private readonly sitterRepository;
    private readonly userService;
    constructor(sitterRepository: Repository<Sitter>, userService: UserService);
    setupProfile(userId: number, setupDto: SitterSetupDto): Promise<Sitter>;
}
