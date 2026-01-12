// src/user/user.entity.ts
import { Booking } from 'src/booking/booking.entity';
import { Notification } from 'src/notification/notification.entity';
import { Pet } from 'src/pet/pet.entity';
import { Review } from 'src/review/review.entity';
import { Sitter } from 'src/sitter/sitter.entity';
import { Post } from 'src/posts/posts.entity';
import { Comment } from 'src/comments/comments.entity';
import { Like } from 'src/likes/likes.entity';
import { Message } from '../message/message.entity';

import {
  Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany, OneToOne
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn() // 'INT user_id PK'
  id: number;

  @Column() // 'STRING name'
  name: string;

  @Column({
    unique: true,
    nullable: true,
  }) // 'STRING email'
  email: string;

  @Column({
    unique: true,
    nullable: true,
  })
  phone_number: string;

  @Column() // 'STRING password'
  passwordHash: string; // Renamed from 'password' for security

  @Column({ default: 'user' }) // 'STRING role'
  role: string;

  @Column({ nullable: true }) // 'STRING profile_picture'
  profile_picture: string;

  @CreateDateColumn() // 'TIMESTAMP created_at'
  created_at: Date;

  @UpdateDateColumn() // 'TIMESTAMP updated_at'
  updated_at: Date;

  // --- Relationships ---
  @OneToMany(() => Pet, (pet) => pet.owner)
  pets: Pet[];

  @OneToOne(() => Sitter, (sitter) => sitter.user)
  sitterProfile: Sitter;

  @OneToMany(() => Booking, (booking) => booking.owner)
  bookings: Booking[];

  @OneToMany(() => Review, (review) => review.owner)
  reviews: Review[];

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];

  @OneToMany(() => Post, (post) => post.user)
  posts: Post[];

  @OneToMany(() => Comment, (comment) => comment.user)
  comments: Comment[];

  @OneToMany(() => Like, (like) => like.user)
  likes: Like[];

  @OneToMany(() => Message, (message) => message.sender)
  messages: Message[];
}
