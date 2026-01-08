import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Like } from './likes.entity';
import { LikesService } from './likes.service';
import { LikesController } from './like.controller'; // 👈 Import this

@Module({
  imports: [TypeOrmModule.forFeature([Like])],
  controllers: [LikesController], // 👈 ADD THIS LINE
  providers: [LikesService],
  exports: [LikesService]
})
export class LikesModule {}










