import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ActivityLogService } from './activity-log.service';
import { CreateActivityLogDto } from './dto/create-activity-log.dto';
import { UpdateActivityLogDto } from './dto/update-activity-log.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('activity-logs')
@UseGuards(JwtAuthGuard)
export class ActivityLogController {
  constructor(private readonly activityLogService: ActivityLogService) {}

  /**
   * ✅ UPDATED: Create activity for multiple pets at once
   * POST /activity-logs
   * Body: { pet_ids: [1, 2, 3], activity_type: 'walk', ... }
   */
  @Post()
  async create(
    @Body() createDto: CreateActivityLogDto,
    @Request() req,
  ) {
    return this.activityLogService.createForMultiplePets(
      createDto.pet_ids,
      createDto,
      req.user.id,
    );
  }

  /**
   * ✅ KEPT: Legacy endpoint for backward compatibility
   * POST /activity-logs/pets/:petId
   * (Will internally convert single petId to array)
   */
  @Post('pets/:petId')
  async createLegacy(
    @Param('petId', ParseIntPipe) petId: number,
    @Body() createDto: CreateActivityLogDto,
    @Request() req,
  ) {
    // Override pet_ids with single petId from route
    const dtoWithPetId = { ...createDto, pet_ids: [petId] };
    
    const activities = await this.activityLogService.createForMultiplePets(
      [petId],
      dtoWithPetId,
      req.user.id,
    );
    
    // Return single activity for backward compatibility
    return activities[0];
  }

  /**
   * Get all activities for a specific pet
   * GET /activity-logs/pets/:petId
   */
  @Get('pets/:petId')
  async findAllByPet(
    @Param('petId', ParseIntPipe) petId: number,
    @Query('type') type?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Request() req?,
  ) {
    return this.activityLogService.findAllByPet(
      petId,
      req.user.id,
      { type, startDate, endDate },
    );
  }

  /**
   * Get activity statistics for a specific pet
   * GET /activity-logs/pets/:petId/stats?period=week
   */
  @Get('pets/:petId/stats')
  async getStats(
    @Param('petId', ParseIntPipe) petId: number,
    @Query('period') period: 'day' | 'week' | 'month',
    @Request() req,
  ) {
    return this.activityLogService.getStats(petId, req.user.id, period);
  }

  /**
   * Get a single activity by ID
   * GET /activity-logs/:id
   */
  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.activityLogService.findOne(id, req.user.id);
  }

  /**
   * Update an activity
   * PUT /activity-logs/:id
   */
  @Put(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateActivityLogDto,
    @Request() req,
  ) {
    return this.activityLogService.update(id, updateDto, req.user.id);
  }

  /**
   * Delete an activity
   * DELETE /activity-logs/:id
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    await this.activityLogService.remove(id, req.user.id);
  }
}