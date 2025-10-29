import { Controller, Post, Body, Param, ParseIntPipe, UsePipes, ValidationPipe, Get } from '@nestjs/common';
import { HealthRecordService } from './health-record.service';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';

@Controller()
export class HealthRecordController {
  constructor(private readonly healthRecordService: HealthRecordService) {}

  @Post('/pets/:petId/health-records')
  @UsePipes(new ValidationPipe({ transform: true }))
  create(
    @Param('petId', ParseIntPipe) petId: number,
    @Body() createHealthRecordDto: CreateHealthRecordDto,
  ) {
    return this.healthRecordService.create(petId, createHealthRecordDto);
  }

  @Get('/pets/:petId/health-records')
  findAllForPet(@Param('petId', ParseIntPipe) petId: number) {
    return this.healthRecordService.findAllForPet(petId);
  }
}


