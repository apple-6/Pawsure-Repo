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
  });

  // 🔧 Serve static files from the 'uploads' directory
  // This makes files in ./uploads accessible at http://localhost:3000/uploads/...
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });
  
  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');

  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();