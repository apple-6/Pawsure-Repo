import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, LessThan, Not, In } from 'typeorm';
import { Event, EventStatus } from './entities/event.entity';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { Pet } from '../pet/pet.entity';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event)
    private eventsRepository: Repository<Event>,
    @InjectRepository(Pet)
    private petRepository: Repository<Pet>,
  ) {}

  async create(createEventDto: CreateEventDto) {
    // ✅ Logic to handle "One Event, Multiple Pets"
    const petsToCreateFor: number[] = [];

    if (createEventDto.pet_ids && createEventDto.pet_ids.length > 0) {
       petsToCreateFor.push(...createEventDto.pet_ids);
    } else if (createEventDto.petId) {
       petsToCreateFor.push(createEventDto.petId);
    }

    const createdEvents: Event[] = []; // Explicit type

    for (const pId of petsToCreateFor) {
      const event = this.eventsRepository.create({
        ...createEventDto,
        petId: pId,
        pet: { id: pId } as any,
      });
      const saved = await this.eventsRepository.save(event);
      createdEvents.push(saved);
    }

    return createdEvents.length === 1 ? createdEvents[0] : createdEvents;
  }

  // ✅ NEW: Find all events for an Owner (User)
  async findAllByOwner(userId: number) {
    // 🛡️ Safety Check: Prevent NaN crash
    if (!userId || isNaN(userId)) {
      console.error('❌ findAllByOwner called with invalid userId:', userId);
      return []; 
    }

    // 1. Get owner's pets
    const ownerPets = await this.petRepository.find({ where: { owner: { id: userId } } });
    const petIds = ownerPets.map(p => p.id);

    if (petIds.length === 0) return []; // No pets = no events

    // 2. Mark past 'upcoming' as 'pending'
    await this.eventsRepository.update(
      {
        pet: { id: In(petIds) },
        dateTime: LessThan(new Date()),
        status: EventStatus.UPCOMING,
      },
      { status: EventStatus.PENDING },
    );

    // 3. Fetch events
    return this.eventsRepository.find({
      where: {
        pet: { owner: { id: userId } }
      },
      relations: ['pet'],
      order: { dateTime: 'ASC' },
    });
  }

  // ✅ NEW: Find upcoming for Owner
  async findUpcomingByOwner(userId: number, limit: number) {
    // 🛡️ Safety Check
    if (!userId || isNaN(userId)) {
      console.error('❌ findUpcomingByOwner called with invalid userId:', userId);
      return [];
    }

    return this.eventsRepository.find({
      where: {
        pet: { owner: { id: userId } },
        dateTime: MoreThan(new Date()),
        status: Not(EventStatus.MISSED)
      },
      relations: ['pet'],
      order: { dateTime: 'ASC' },
      take: limit,
    });
  }

  // Existing methods...
  async findAllByPet(petId: number): Promise<Event[]> {
    if (!petId || isNaN(petId)) return [];
    return this.eventsRepository.find({
      where: { pet: { id: petId } },
      order: { dateTime: 'ASC' },
    });
  }

  async findOne(id: number): Promise<Event> {
    const event = await this.eventsRepository.findOne({ where: { id } });
    if (!event) throw new NotFoundException(`Event with ID ${id} not found`);
    return event;
  }

  async update(id: number, updateEventDto: UpdateEventDto): Promise<Event> {
    const event = await this.findOne(id);
    Object.assign(event, updateEventDto);
    if (updateEventDto.petId) {
      event.pet = { id: updateEventDto.petId } as any;
    }
    return this.eventsRepository.save(event);
  }

  async remove(id: number): Promise<void> {
    const result = await this.eventsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Event with ID ${id} not found`);
    }
  }
}