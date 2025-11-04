import { Module } from '@nestjs/common';
import { SitterService } from './sitter.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';
import { SitterController } from './sitter.controller';
import { UserModule } from 'src/user/user.module';
import { AuthModule } from 'src/auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Sitter]),
    UserModule,
    AuthModule,
  ],
  controllers: [SitterController],
  providers: [SitterService],
  exports: [SitterService],
})
export class SitterModule {}
