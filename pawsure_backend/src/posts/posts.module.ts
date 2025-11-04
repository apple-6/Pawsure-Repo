import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from './posts.entity';
import { PostsService } from './posts.service';
import { PetService } from '../pet/pet.service';
import { PetController } from '../pet/pet.controller';
import { Pet } from '../pet/pet.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Post])],
  providers: [PostsService],
  exports: [PostsService]
})
export class PostsModule {}










