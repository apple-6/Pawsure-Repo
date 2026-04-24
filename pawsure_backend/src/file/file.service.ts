import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';
import * as streamifier from 'streamifier';

@Injectable()
export class FileService {
  private readonly logger = new Logger(FileService.name);

  constructor(private configService: ConfigService) {
    cloudinary.config({
      cloud_name: this.configService.get<string>('CLOUDINARY_CLOUD_NAME'),
      api_key: this.configService.get<string>('CLOUDINARY_API_KEY'),
      api_secret: this.configService.get<string>('CLOUDINARY_API_SECRET'),
    });
  }

  async uploadPublicFile(
    dataBuffer: Buffer,
    fileName: string,
    folder: string = 'pawsure',
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: folder,
          public_id: fileName.split('.')[0], // Use original filename without extension
          resource_type: 'auto',
        },
        (error, result) => {
          if (error) {
            this.logger.error('Cloudinary upload failed:', error);
            return reject(error);
          }
          this.logger.log(`File uploaded to Cloudinary: ${result.secure_url}`);
          resolve(result.secure_url);
        },
      );

      streamifier.createReadStream(dataBuffer).pipe(uploadStream);
    });
  }
}
