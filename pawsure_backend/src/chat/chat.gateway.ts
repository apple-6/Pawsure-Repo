// src/chat/chat.gateway.ts
import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from '../message/message.entity';
import { User } from '../user/user.entity';

@WebSocketGateway({ cors: true }) 
export class ChatGateway {
  @WebSocketServer()
  server: Server;

  constructor(
    @InjectRepository(Message)
    private messageRepo: Repository<Message>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  @SubscribeMessage('joinRoom')
  handleJoinRoom(client: Socket, room: string) {
    client.join(room);
    console.log(`✅ Client ${client.id} joined room: ${room}`);
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { room: string; text: string; senderId: number },
  ) {
    console.log("📩 Received payload:", payload);

    try {
      // 1. Find the Sender in the Database
      const sender = await this.userRepo.findOne({ where: { id: payload.senderId } });

      if (!sender) {
        console.error(`❌ ERROR: User with ID ${payload.senderId} does not exist in the database!`);
        return; 
      }

      // 2. Create the Message Object
      const newMessage = this.messageRepo.create({
        text: payload.text,
        room: payload.room,
        sender: sender, 
      });

      // 3. Save to Database
      const savedMessage = await this.messageRepo.save(newMessage);
      console.log("💾 Saved to DB:", savedMessage);

      // 4. Send to everyone in the room
      this.server.to(payload.room).emit('receiveMessage', {
        text: savedMessage.text,
        senderId: payload.senderId,
        time: savedMessage.created_at,
      });

    } catch (error) {
      console.error("🔥 DATABASE SAVE FAILED:", error);
    }
  }
}