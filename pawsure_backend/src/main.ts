import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
<<<<<<< HEAD
  app.enableCors({ 
      origin: '*',
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
      allowedHeaders: '*',
    });    
  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');
=======
  app.enableCors({ origin: true, credentials: true });
  await app.listen(process.env.PORT ?? 3000);
>>>>>>> fff8443f8b89299d113154623b7961e3a6d92706
  // --- ADD THIS LINE ---
  // This allows your frontend (e.g., http://localhost:5173)
  // to make requests to your backend (http://localhost:3000)
  app.enableCors();
  // ---------------------
}
bootstrap();
