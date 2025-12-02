import { Repository } from 'typeorm';
import { Sitter } from './sitter.entity';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
import { User } from '../user/user.entity';
import { UserService } from '../user/user.service';
import { FileService } from '../file/file.service';
export declare class SitterService {
    private readonly sitterRepository;
    private readonly userService;
    private readonly fileService;
    private userRepository;
    constructor(sitterRepository: Repository<Sitter>, userService: UserService, fileService: FileService, userRepository: Repository<User>);
    create(createSitterDto: CreateSitterDto, userId: number, file?: Express.Multer.File): Promise<Sitter>;
    findAll(minRating?: number): Promise<Sitter[]>;
    findOne(id: number): Promise<Sitter>;
    findByUserId(userId: number): Promise<Sitter | null>;
    update(id: number, updateSitterDto: UpdateSitterDto, userId: number): Promise<Sitter>;
    remove(id: number, userId: number): Promise<void>;
    updateRating(id: number): Promise<Sitter>;
    searchByAvailability(date: string): Promise<Sitter[]>;
}
