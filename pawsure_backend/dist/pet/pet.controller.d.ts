import { PetService } from './pet.service';
import { CreatePetDto } from './dto/create-pet.dto';
export declare class PetController {
    private readonly petService;
    constructor(petService: PetService);
    getMyPets(req: any): Promise<import("./pet.entity").Pet[]>;
    debugAllPets(): Promise<{
        total: number;
        pets: {
            id: number;
            name: string;
            ownerId: number;
            species: string;
            breed: string;
        }[];
    }>;
    getPetsByOwnerParam(ownerId: string): Promise<import("./pet.entity").Pet[]>;
    createPet(createPetDto: CreatePetDto, file: any, req: any): Promise<import("./pet.entity").Pet>;
}
