import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Pet } from './pet.entity';
import { CreatePetDto } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto';

@Injectable()
export class PetService {
  constructor(
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
  ) {}

  async create(createPetDto: CreatePetDto): Promise<Pet> {
    const pet = this.petRepository.create(createPetDto);
    return await this.petRepository.save(pet);
  }

  async findAll(ownerId?: number): Promise<Pet[]> {
    if (ownerId) {
      return await this.petRepository.find({
        where: { ownerId },
        relations: ['owner'],
        order: { created_at: 'DESC' },
      });
    }
    return await this.petRepository.find({
      relations: ['owner'],
      order: { created_at: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Pet> {
    const pet = await this.petRepository.findOne({
      where: { id },
      relations: ['owner', 'activityLogs', 'healthRecords'],
    });

    if (!pet) {
      throw new NotFoundException(`Pet with ID ${id} not found`);
    }

    return pet;
  }

  async findByOwner(ownerId: number): Promise<Pet[]> {
    return await this.petRepository.find({
      where: { ownerId },
      relations: ['owner'],
      order: { created_at: 'DESC' },
    });
  }

  async update(
    id: number,
    updatePetDto: UpdatePetDto,
    userId: number,
  ): Promise<Pet> {
    const pet = await this.findOne(id);

    // Check if the user is the owner
    if (pet.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own pets');
    }

    Object.assign(pet, updatePetDto);
    return await this.petRepository.save(pet);
  }

  async remove(id: number, userId: number): Promise<void> {
    const pet = await this.findOne(id);

    // Check if the user is the owner
    if (pet.ownerId !== userId) {
      throw new ForbiddenException('You can only delete your own pets');
    }

    await this.petRepository.remove(pet);
  }

  async updateStreak(id: number, streak: number): Promise<Pet> {
    const pet = await this.findOne(id);
    pet.streak = streak;
    return await this.petRepository.save(pet);
  }

  async updateMoodRating(id: number, moodRating: number): Promise<Pet> {
    const pet = await this.findOne(id);
    pet.mood_rating = moodRating;
    return await this.petRepository.save(pet);
  }
}