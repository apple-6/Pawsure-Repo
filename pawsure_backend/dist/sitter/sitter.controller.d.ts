import { SitterService } from './sitter.service';
import { SitterSetupDto } from './dto/sitter-setup.dto';
import { User } from 'src/user/user.entity';
export declare class SitterController {
    private readonly sitterService;
    constructor(sitterService: SitterService);
    setupProfile(setupDto: SitterSetupDto, user: User): Promise<import("./sitter.entity").Sitter>;
}
