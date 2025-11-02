import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ?? 3000);
  // --- ADD THIS LINE ---
  // This allows your frontend (e.g., http://localhost:5173)
  // to make requests to your backend (http://localhost:3000)
  app.enableCors();
  // ---------------------
}
bootstrap();
