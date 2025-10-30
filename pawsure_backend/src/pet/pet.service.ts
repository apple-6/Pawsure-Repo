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
        name,
        breed,
        photoUrl, 
        // Assuming a relation where 'owner' is a User entity with 'id'
        owner: { id: ownerId }, 
      });

      // Save the new pet to the database (Supabase via TypeORM)
      return this.petRepository.save(newPet);
    }
}