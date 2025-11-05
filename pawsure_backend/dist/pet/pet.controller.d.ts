import { PetService } from './pet.service';
export declare class PetController {
    private readonly petService;
    constructor(petService: PetService);
    findAll(): Promise<import("./pet.entity").Pet[]>;
}
