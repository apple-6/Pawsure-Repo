// pawsure_backend/src/events/events.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, LessThan, Not } from 'typeorm';
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

  /**
   * ✅ FIXED: Create ONE event with multiple pet_ids
   * Not multiple separate events
   */
  async create(createEventDto: CreateEventDto) {
    const petsToInclude: number[] = [];

    // Collect pet IDs from either pet_ids array or single petId
    if (createEventDto.pet_ids && createEventDto.pet_ids.length > 0) {
      petsToInclude.push(...createEventDto.pet_ids);
    } else if (createEventDto.petId) {
      petsToInclude.push(createEventDto.petId);
    }

    // ✅ CRITICAL FIX: Parse as UTC explicitly
    const dateTimeUtc = new Date(createEventDto.dateTime);
    
    console.log('📥 Received dateTime:', createEventDto.dateTime);
    console.log('📅 Parsed as Date:', dateTimeUtc.toISOString());

    // ✅ Create ONE event with array of pet IDs
    const event = this.eventsRepository.create({
      title: createEventDto.title,
      dateTime: dateTimeUtc, // ✅ Store UTC
      eventType: createEventDto.eventType,
      status: createEventDto.status || EventStatus.UPCOMING,
      location: createEventDto.location,
      notes: createEventDto.notes,
      pet_ids: petsToInclude, // ✅ Store all pet IDs in array
      petId: petsToInclude[0], // ✅ For backward compatibility, use first pet
      pet: { id: petsToInclude[0] } as any,
    });

    const saved = await this.eventsRepository.save(event);

    console.log('✅ Created event:', {
      id: saved.id,
      title: saved.title,
      pet_ids: saved.pet_ids,
      dateTime: saved.dateTime.toISOString(),
    });

    return saved;
  }

  /**
   * ✅ NEW: Find all events for an Owner
   * Uses PostgreSQL overlap operator (&&) to match pet_ids
   */
  async findAllByOwner(userId: number) {
    if (!userId || isNaN(userId)) {
      console.error('❌ Invalid userId:', userId);
      return [];
    }

    // 1. Get owner's pets
    const ownerPets = await this.petRepository.find({
      where: { owner: { id: userId } },
      select: ['id'],
    });
    const petIds = ownerPets.map(p => p.id);

    if (petIds.length === 0) return [];

    // 2. Mark past 'upcoming' as 'pending'
    await this.eventsRepository
      .createQueryBuilder()
      .update(Event)
      .set({ status: EventStatus.PENDING })
      .where('pet_ids && :petIds', { petIds })
      .andWhere('dateTime < :now', { now: new Date() })
      .andWhere('status = :status', { status: EventStatus.UPCOMING })
      .execute();

    // 3. Fetch events using overlap operator
    const events = await this.eventsRepository
      .createQueryBuilder('event')
      .where('event.pet_ids && :petIds', { petIds })
      .orderBy('event.dateTime', 'ASC')
      .getMany();

    console.log(`✅ Found ${events.length} events for owner ${userId}`);

    return events;
  }

  /**
   * ✅ NEW: Find upcoming events for Owner
   */
  async findUpcomingByOwner(userId: number, limit: number) {
    if (!userId || isNaN(userId)) {
      console.error('❌ Invalid userId:', userId);
      return [];
    }

    const ownerPets = await this.petRepository.find({
      where: { owner: { id: userId } },
      select: ['id'],
    });
    const petIds = ownerPets.map(p => p.id);

    if (petIds.length === 0) return [];

    const now = new Date();

    const events = await this.eventsRepository
      .createQueryBuilder('event')
      .where('event.pet_ids && :petIds', { petIds })
      .andWhere('event.dateTime >= :now', { now })
      .andWhere('event.status != :missed', { missed: EventStatus.MISSED })
      .orderBy('event.dateTime', 'ASC')
      .limit(limit)
      .getMany();

    console.log(`✅ Found ${events.length} upcoming events for owner ${userId}`);

    return events;
  }

  /**
   * Existing methods (unchanged)
   */
  async findAllByPet(petId: number): Promise<Event[]> {
    if (!petId || isNaN(petId)) return [];
    
    return this.eventsRepository
      .createQueryBuilder('event')
      .where(':petId = ANY(event.pet_ids)', { petId })
      .orderBy('event.dateTime', 'ASC')
      .getMany();
  }

  async findOne(id: number): Promise<Event> {
    const event = await this.eventsRepository.findOne({ where: { id } });
    if (!event) throw new NotFoundException(`Event with ID ${id} not found`);
    return event;
  }

  async update(id: number, updateEventDto: UpdateEventDto): Promise<Event> {
    const event = await this.findOne(id);

    // Update basic fields
    if (updateEventDto.title) event.title = updateEventDto.title;
    
    if (updateEventDto.dateTime) {
      // ✅ CRITICAL FIX: Parse as UTC
      const dateTimeUtc = new Date(updateEventDto.dateTime);
      
      console.log('📥 Update received dateTime:', updateEventDto.dateTime);
      console.log('📅 Parsed as Date:', dateTimeUtc.toISOString());
      
      event.dateTime = dateTimeUtc;
    }

    if (updateEventDto.eventType) event.eventType = updateEventDto.eventType;
    if (updateEventDto.status) event.status = updateEventDto.status;
    if (updateEventDto.location !== undefined) event.location = updateEventDto.location;
    if (updateEventDto.notes !== undefined) event.notes = updateEventDto.notes;

    // ✅ Update pet_ids if provided
    if (updateEventDto.pet_ids && updateEventDto.pet_ids.length > 0) {
      event.pet_ids = updateEventDto.pet_ids;
      event.petId = updateEventDto.pet_ids[0]; // Update backward compat field
    } else if (updateEventDto.petId) {
      event.pet_ids = [updateEventDto.petId];
      event.petId = updateEventDto.petId;
    }

    const saved = await this.eventsRepository.save(event);

    console.log('✅ Updated event:', {
      id: saved.id,
      dateTime: saved.dateTime.toISOString(),
      pet_ids: saved.pet_ids,
    });

    return saved;
  }

  async remove(id: number): Promise<void> {
    const result = await this.eventsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Event with ID ${id} not found`);
    }
    console.log(`✅ Deleted event ${id}`);
  }
}