// src/file/file.module.ts

import { Module } from '@nestjs/common';
import { FileService } from './file.service';

@Module({
  providers: [FileService],
  exports: [FileService], // <--- CRITICAL: Must export the service for SitterModule to use it
})
export class FileModule {}
