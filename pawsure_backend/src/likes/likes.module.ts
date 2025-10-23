import { Module } from '@nestjs/common';
import { LikesService } from './likes.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Like } from './likes.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Like])],
  providers: [LikesService],
  exports: [LikesService]
})
export class LikesModule {}
