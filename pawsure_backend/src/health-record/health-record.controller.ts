//pawsure_backend\src\health-record\health-record.controller.ts
import { 
  Controller, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  ParseIntPipe, 
  UsePipes, 
  ValidationPipe, 
  Get,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { HealthRecordService } from './health-record.service';
import { CreateHealthRecordDto } from './dto/create-health-record.dto';
import { UpdateHealthRecordDto } from './dto/update-health-record.dto';

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

  // ✅ NEW: Update health record
  @Put('/health-records/:id')
  @UsePipes(new ValidationPipe({ transform: true }))
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateHealthRecordDto: UpdateHealthRecordDto,
  ) {
    return this.healthRecordService.update(id, updateHealthRecordDto);
  }

  // ✅ NEW: Delete health record
  @Delete('/health-records/:id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.healthRecordService.remove(id);
    return { message: 'Health record deleted successfully' };
  }
}