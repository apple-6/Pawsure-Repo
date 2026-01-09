import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { Pet } from '../pet/pet.entity';
import { AiScan } from './ai-scan.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AiScan, Pet])], 
  controllers: [AiController],
  providers: [AiService],
  exports: [AiService],
})
export class AiModule {}
