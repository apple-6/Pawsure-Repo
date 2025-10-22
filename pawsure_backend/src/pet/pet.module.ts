import { Module } from '@nestjs/common';
import { PetService } from './pet.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Pet } from './pet.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Pet])],
  providers: [PetService],
  exports: [PetService],
})
export class PetModule {}
