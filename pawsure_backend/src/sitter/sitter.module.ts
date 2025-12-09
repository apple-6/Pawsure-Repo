import { Module } from '@nestjs/common';
import { SitterService } from './sitter.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';
import { UserModule } from 'src/user/user.module';
import { AuthModule } from 'src/auth/auth.module';
import { FileModule } from '../file/file.module';
import { User } from 'src/user/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Sitter, User]),
    UserModule,
    AuthModule,
    FileModule,
  ],
  controllers: [],
  providers: [SitterService],
  exports: [SitterService],
})
export class SitterModule {}
