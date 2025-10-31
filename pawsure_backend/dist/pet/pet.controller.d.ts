import { PetService } from './pet.service';
import { CreatePetDto } from './dto/create-pet.dto';
export declare class PetController {
    private readonly petService;
    constructor(petService: PetService);
    createPet(createPetDto: CreatePetDto, file: Express.Multer.File, req: any): Promise<import("./pet.entity").Pet>;
    getPetsByOwnerParam(ownerId: string): Promise<import("./pet.entity").Pet[]>;
    getPetsByOwnerQuery(ownerId?: string): Promise<import("./pet.entity").Pet[]>;
}
