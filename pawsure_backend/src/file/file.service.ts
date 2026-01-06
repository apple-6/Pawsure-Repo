// src/file/file.service.ts

import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs/promises';

// src/file/file.service.ts

@Injectable()
export class FileService {
    private readonly uploadPath = path.join(process.cwd(), 'uploads');
    
    // Add this to get your base URL from environment variables or hardcode for now
    private readonly baseUrl = process.env.BACKEND_URL || 'http://localhost:3000';

    async uploadPublicFile(dataBuffer: Buffer, fileName: string, folder: string = 'general'): Promise<string> {
        const uniqueFileName = `${Date.now()}-${fileName}`;
        const targetDir = path.join(this.uploadPath, folder);
        
        await fs.mkdir(targetDir, { recursive: true });
        const filePath = path.join(targetDir, uniqueFileName);
        await fs.writeFile(filePath, dataBuffer);

        // ✅ FIX: Return the absolute URL instead of a relative path
        return `${this.baseUrl}/uploads/${folder}/${uniqueFileName}`; 
    }
}
