// src/chat/chat.gateway.ts
import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from '../message/message.entity';
import { User } from '../user/user.entity';

// CORS enabled so your Flutter app can connect
@WebSocketGateway({ cors: true }) 
export class ChatGateway {
  @WebSocketServer()
  server: Server;

  constructor(
    @InjectRepository(Message)
    private messageRepo: Repository<Message>,
    @InjectRepository(User) // Inject User repo to verify sender
    private userRepo: Repository<User>,
  ) {}

  // 1. When User Enters the Screen -> Join a "Room"
  @SubscribeMessage('joinRoom')
  handleJoinRoom(client: Socket, room: string) {
    client.join(room);
    console.log(`Client joined room: ${room}`);
  }

  // 2. When User Sends Message -> Save to DB & Broadcast to Room
  @SubscribeMessage('sendMessage')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { room: string; text: string; senderId: number },
  ) {
    // A. Save to Database (Postgres)
    const sender = await this.userRepo.findOne({ where: { id: payload.senderId } });
    if (!sender) {
      console.error(`Sender with ID ${payload.senderId} not found.`);
      return; 
    }
    const newMessage = this.messageRepo.create({
      text: payload.text,
      room: payload.room,
      sender: sender,
    });
    await this.messageRepo.save(newMessage);

    // B. Send to everyone in that room (Real-time!)
    this.server.to(payload.room).emit('receiveMessage', {
      text: payload.text,
      senderId: payload.senderId,
      time: new Date().toISOString(),
    });
  }
}