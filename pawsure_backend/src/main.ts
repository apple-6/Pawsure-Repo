process.env.TZ = 'UTC';

import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  // Create app with NestExpressApplication type to enable static assets
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Keep this ONE robust configuration
  app.enableCors({ 
      origin: '*', // Allows all origins (good for development)
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
      allowedHeaders: '*',
      credentials: true,
  });

  // 🔧 Serve static files from the 'uploads' directory
  // UPDATED: Using process.cwd() ensures we look in the project root, not 'dist'
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads/',
  });
  
  // 👇 ADDED DEBUG LOGGING 👇
  console.log('------------------------------------------------');
  console.log('📂 STATIC FILE DEBUGGER');
  console.log('👉 Current Working Directory (CWD):', process.cwd());
  console.log('👉 Static Assets Path:', join(process.cwd(), 'uploads'));
  console.log('------------------------------------------------');
  // 👆 END DEBUG LOGGING 👆

  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');

  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();