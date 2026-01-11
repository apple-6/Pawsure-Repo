// src/chat/chat.gateway.ts
import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from '../message/message.entity';
import { User } from '../user/user.entity';

@WebSocketGateway({ 
  cors: {
        origin: '*', // ✅ Allow all origins for development
    credentials: true,
  },
  transports: ['websocket', 'polling'],
}) 
export class ChatGateway {
  @WebSocketServer()
  server: Server;

  constructor(
    @InjectRepository(Message)
    private messageRepo: Repository<Message>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  // ✅ Track connections
  handleConnection(client: Socket) {
    console.log(`✅ Client connected: ${client.id}`);
  }

  // ✅ Track disconnections
  handleDisconnect(client: Socket) {
    console.log(`❌ Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinRoom')
  handleJoinRoom(client: Socket, room: string) {
    client.join(room);
    console.log(`✅ Client ${client.id} joined room: ${room}`);

    client.emit('joinedRoom', { room, success: true });
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { room: string; text: string; senderId: number },
  ) {
    console.log("📩 Received payload:", payload);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("📩 NEW MESSAGE RECEIVED");
    console.log("   Room:", payload.room);
    console.log("   Text:", payload.text);
    console.log("   Sender ID:", payload.senderId);
    console.log("   Client ID:", client.id);

    try {
      // Check how many clients are in the room
      const socketsInRoom = await this.server.in(payload.room).fetchSockets();
      console.log(`   👥 Clients in room ${payload.room}: ${socketsInRoom.length}`);
      socketsInRoom.forEach((socket, idx) => {
        console.log(`      ${idx + 1}. ${socket.id}`);
      });

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
      console.log("   ID:", savedMessage.id);
      console.log("   Created at:", savedMessage.created_at);

      // Prepare broadcast data
      const broadcastData = {
        text: savedMessage.text,
        senderId: payload.senderId,
        timestamp: savedMessage.created_at?.toISOString() || new Date().toISOString(),
      };

      console.log("📤 Broadcasting to room:", payload.room);
      console.log("   Data:", JSON.stringify(broadcastData));
      
      // ✅ Broadcast to ALL clients in the room (including sender)
      this.server.to(payload.room).emit('receiveMessage', broadcastData);
      
      console.log("✅ Broadcast complete!");
      console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    } catch (error) {
      console.error("🔥 DATABASE SAVE FAILED:", error);
    }
  }
}