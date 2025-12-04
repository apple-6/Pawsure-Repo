import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, LessThan, Not } from 'typeorm'; // 👈 Added MoreThan, LessThan, Not
import { Event, EventStatus } from './entities/event.entity'; // 👈 Added EventStatus
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event)
    private eventsRepository: Repository<Event>,
  ) {}

  async create(createEventDto: CreateEventDto): Promise<Event> {
    const event = this.eventsRepository.create({
      ...createEventDto,
      pet: { id: createEventDto.petId },
    });
    return this.eventsRepository.save(event);
  }

  async findAllByPet(petId: number): Promise<Event[]> {
    // 1. Auto-update: Mark past 'upcoming' events as 'pending'
    await this.eventsRepository.update(
      {
        pet: { id: petId },
        dateTime: LessThan(new Date()),
        status: EventStatus.UPCOMING,
      },
      { status: EventStatus.PENDING },
    );

    // 2. Fetch all
    return this.eventsRepository.find({
      where: { pet: { id: petId } },
      order: { dateTime: 'ASC' },
    });
  }

  // 🆕 NEW METHOD: Get next few events
  async findUpcoming(petId: number, limit: number): Promise<Event[]> {
    return this.eventsRepository.find({
      where: {
        pet: { id: petId },
        dateTime: MoreThan(new Date()), // Future events only
        status: Not(EventStatus.MISSED) // Don't show missed ones
      },
      order: { dateTime: 'ASC' },
      take: limit,
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