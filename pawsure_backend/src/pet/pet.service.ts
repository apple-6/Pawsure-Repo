// src/pet/pet.service.ts

import { Injectable } from '@nestjs/common';
import { Repository } from 'typeorm'; 
import { InjectRepository } from '@nestjs/typeorm';
import { Pet } from './pet.entity';
import { CreatePetDto } from './dto/create-pet.dto';

// CRITICAL CORRECTION: Add the @Injectable() decorator
@Injectable() 
export class PetService {
    constructor(
      @InjectRepository(Pet)
      private petRepository: Repository<Pet>, 
    ) {}

    async createPet(createPetDto: CreatePetDto): Promise<Pet> {
      // Destructure the DTO
      const { name, breed, photoUrl, ownerId } = createPetDto;
      
      // Create a new Pet entity instance
      const newPet = this.petRepository.create({
        name: createPetDto.name,
        breed: createPetDto.breed,
        species: createPetDto.species, // 🟢 CRITICAL: Must be here!
        dob: createPetDto.dob ? new Date(createPetDto.dob) : undefined,
        photoUrl, 
        // Assuming a relation where 'owner' is a User entity with 'id'
        owner: { id: ownerId }, 
      });

      // Save the new pet to the database (Supabase via TypeORM)
      return await this.petRepository.save(newPet);
    }

    async findPetsByOwner(ownerId: number): Promise<Pet[]> {
      return await this.petRepository.find({ where: { owner: { id: ownerId } } });
    }
}