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

  @Post('pets/:petId')
  async create(
    @Param('petId', ParseIntPipe) petId: number,
    @Body() createDto: CreateActivityLogDto,
    @Request() req,
  ) {
    return this.activityLogService.create(petId, createDto, req.user.id);
  }

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
      { type, startDate, endDate }
    );
  }

  @Get('pets/:petId/stats')
  async getStats(
    @Param('petId', ParseIntPipe) petId: number,
    @Query('period') period: 'day' | 'week' | 'month',
    @Request() req,
  ) {
    return this.activityLogService.getStats(petId, req.user.id, period);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.activityLogService.findOne(id, req.user.id);
  }

  @Put(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateActivityLogDto,
    @Request() req,
  ) {
    return this.activityLogService.update(id, updateDto, req.user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    await this.activityLogService.remove(id, req.user.id);
  }
}
