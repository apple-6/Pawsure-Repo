// pawsure_backend/src/pet/pet.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PetService } from './pet.service';
import { PetController } from './pet.controller';
import { Pet } from './pet.entity';
import { FileModule } from '../file/file.module';
// src/pet/pet.module.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([Pet]),
    FileModule, // This must be here!
  ],
  controllers: [PetController],
  providers: [PetService],
})
export class PetModule {}