import { SitterService } from './sitter.service';
import { CreateSitterDto } from './dto/create-sitter.dto';
import { UpdateSitterDto } from './dto/update-sitter.dto';
export declare class SitterController {
    private readonly sitterService;
    constructor(sitterService: SitterService);
    create(createSitterDto: CreateSitterDto, req: any): Promise<import("./sitter.entity").Sitter>;
    findAll(minRating?: string): Promise<import("./sitter.entity").Sitter[]>;
    searchByAvailability(date?: string): Promise<import("./sitter.entity").Sitter[]>;
    getMyProfile(req: any): Promise<import("./sitter.entity").Sitter | null>;
    findOne(id: number): Promise<import("./sitter.entity").Sitter>;
    update(id: number, updateSitterDto: UpdateSitterDto, req: any): Promise<import("./sitter.entity").Sitter>;
    remove(id: number, req: any): Promise<void>;
}
