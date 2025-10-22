import { Module } from '@nestjs/common';
import { SitterService } from './sitter.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Sitter])],
  providers: [SitterService],
  exports: [SitterService]
})
export class SitterModule {}
