import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Post()
  create(@Body() createEventDto: CreateEventDto) {
    return this.eventsService.create(createEventDto);
  }

  // 🆕 NEW ROUTE: Must be defined BEFORE @Get(':id')
  @Get('upcoming')
  findUpcoming(@Query('petId') petId: string, @Query('limit') limit: string) {
    return this.eventsService.findUpcoming(+petId, +limit || 3);
  }

  @Get()
  findAll(@Query('petId') petId: string) {
    return this.eventsService.findAllByPet(+petId);
  }

  // 👇 The dynamic route must be last
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.eventsService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateEventDto: UpdateEventDto) {
    return this.eventsService.update(+id, updateEventDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.eventsService.remove(+id);
  }
}