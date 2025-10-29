
import { Controller, Get } from '@nestjs/common';
import { PetService } from './pet.service';

@Controller('pets') // This controller handles all routes starting with /pets
export class PetController {
  constructor(private readonly petService: PetService) {}
    
  @Get()
  findAll() {
    return this.petService.findAll();
  }
  
}