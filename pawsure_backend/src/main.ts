import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express'; // Important!
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  // 1. Add <NestExpressApplication> here so TypeScript sees the static methods
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // 2. This maps the URL path to your local folder
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads/', // This matches the start of your database string
  });

  await app.listen(3000);
}
bootstrap();