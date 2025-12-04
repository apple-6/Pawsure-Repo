// src/file/file.service.ts

import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs/promises';

@Injectable()
export class FileService {
    // Define a basic storage path (adjust as needed for S3, etc.)
    private readonly uploadPath = path.join(process.cwd(), 'uploads');

    async uploadPublicFile(dataBuffer: Buffer, fileName: string, folder: string = 'general'): Promise<string> {
        const uniqueFileName = `${Date.now()}-${fileName}`;
        const targetDir = path.join(this.uploadPath, folder);
        
        // 1. Ensure the directory exists
        await fs.mkdir(targetDir, { recursive: true });

        // 2. Write the file buffer to the disk
        const filePath = path.join(targetDir, uniqueFileName);
        await fs.writeFile(filePath, dataBuffer);

        // 3. Return the public URL or path (adjust for production S3/CDN URL)
        // For local development, returning the relative path is common:
        return `/uploads/${folder}/${uniqueFileName}`; 
    }
}
