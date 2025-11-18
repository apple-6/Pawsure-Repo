import { Repository } from 'typeorm';
import { Pet } from './pet.entity';
export declare class PetService {
    private petRepository;
    constructor(petRepository: Repository<Pet>);
    findAll(): Promise<Pet[]>;
}
