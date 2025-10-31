import { Repository } from 'typeorm';
import { Pet } from './pet.entity';
import { CreatePetDto } from './dto/create-pet.dto';
export declare class PetService {
    private petRepository;
    constructor(petRepository: Repository<Pet>);
    createPet(createPetDto: CreatePetDto): Promise<Pet>;
    findPetsByOwner(ownerId: number): Promise<Pet[]>;
}
