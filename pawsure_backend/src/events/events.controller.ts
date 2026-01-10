import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  Query, 
  Request, 
  UseGuards 
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport'; // ✅ Import standard AuthGuard
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  // ✅ Create Event (Protected)
  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() createEventDto: CreateEventDto) {
    return this.eventsService.create(createEventDto);
  }

  // ✅ NEW: Get All Events for Logged in Owner (Protected)
  @UseGuards(AuthGuard('jwt')) // 🔒 This populates req.user
  @Get('owner/all')
  findAllOwnerEvents(@Request() req) {
    const userId = req.user.userId || req.user.id || req.user.sub; // Handle different token structures
    return this.eventsService.findAllByOwner(+userId);
  }

  // ✅ NEW: Get Upcoming for Owner (Protected)
  @UseGuards(AuthGuard('jwt')) // 🔒 This populates req.user
  @Get('owner/upcoming')
  findUpcomingOwner(@Request() req, @Query('limit') limit: string) {
    const userId = req.user.userId || req.user.id || req.user.sub;
    return this.eventsService.findUpcomingByOwner(+userId, +limit || 3);
  }

  // Public/Shared routes (or add Guards if needed)
  @Get('upcoming')
  findUpcoming(@Query('petId') petId: string, @Query('limit') limit: string) {
    return this.eventsService.findAllByPet(+petId);
  }

  @Get()
  findAll(@Query('petId') petId: string) {
    return this.eventsService.findAllByPet(+petId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.eventsService.findOne(+id);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateEventDto: UpdateEventDto) {
    return this.eventsService.update(+id, updateEventDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.eventsService.remove(+id);
  }
}