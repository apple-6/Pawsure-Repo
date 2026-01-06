import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from '../message/message.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('chat')
export class ChatController {
  constructor(
    @InjectRepository(Message)
    private messageRepo: Repository<Message>,
  ) {}

  @UseGuards(JwtAuthGuard)
  @Get(':room') // Endpoint: /chat/booking-123
  async getMessages(@Param('room') room: string) {
    return await this.messageRepo.find({
      where: { room },
      relations: ['sender'], // So we know who sent it
      order: { created_at: 'ASC' }, // Oldest first
    });
  }
}