import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Automatically strip properties that are not in the DTO
      transform: true,  // Automatically transform payloads to DTO class instances
    }),
  );  

  await app.listen(process.env.PORT ?? 3000);
  // --- ADD THIS LINE ---
  // This allows your frontend (e.g., http://localhost:5173)
  // to make requests to your backend (http://localhost:3000)
  app.enableCors();
  // ---------------------
}
bootstrap();
