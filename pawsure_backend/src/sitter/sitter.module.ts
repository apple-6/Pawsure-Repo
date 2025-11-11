import { Module } from '@nestjs/common';
import { SitterService } from './sitter.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';
import { SitterController } from './sitter.controller';
import { UserModule } from 'src/user/user.module';
import { AuthModule } from 'src/auth/auth.module';
import { FileModule } from '../file/file.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Sitter]),
    UserModule,
    AuthModule,
    FileModule,
  ],
  controllers: [SitterController],
  providers: [SitterService],
  exports: [SitterService],
})
export class SitterModule {}
