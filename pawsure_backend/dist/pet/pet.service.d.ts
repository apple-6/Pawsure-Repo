import { Repository } from 'typeorm';
import { Pet } from './pet.entity';
import { CreatePetDto } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto';
export declare class PetService {
    private petRepository;
    constructor(petRepository: Repository<Pet>);
    create(createPetDto: CreatePetDto): Promise<Pet>;
    findAll(ownerId?: number): Promise<Pet[]>;
    findOne(id: number): Promise<Pet>;
    findByOwner(ownerId: number): Promise<Pet[]>;
    update(id: number, updatePetDto: UpdatePetDto, userId: number): Promise<Pet>;
    remove(id: number, userId: number): Promise<void>;
    updateStreak(id: number, streak: number): Promise<Pet>;
    updateMoodRating(id: number, moodRating: number): Promise<Pet>;
}
