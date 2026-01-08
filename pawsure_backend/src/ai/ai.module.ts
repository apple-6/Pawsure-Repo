import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
// import { ConfigModule } from '@nestjs/config'; // <-- No longer needed

@Module({
  // imports: [ConfigModule], // <-- No longer needed
  controllers: [AiController],
  providers: [AiService],
  exports: [AiService],
})
export class AiModule {}
