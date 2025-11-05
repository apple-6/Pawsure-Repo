import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Pet } from './pet.entity';

@Injectable()
export class PetService {
  constructor(
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
  ) {}

  // --- THIS IS THE NEW METHOD WE WILL ADD ---
  async findAll(): Promise<Pet[]> {
    // This finds and returns all records from the 'pets' table
    return this.petRepository.find();
  }
  
  // (Other methods like 'create', 'findOne' etc. may be here)
}
