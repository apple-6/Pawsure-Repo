import { 
  Controller, 
  Put, 
  Body, 
  UseGuards, 
  Request, 
  UseInterceptors, 
  UploadedFile 
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UserService } from './user.service';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'; 

@Controller('user')
export class UserController {
  constructor(private userService: UserService) {}

  @UseGuards(JwtAuthGuard)
  @Put('update')
  @UseInterceptors(FileInterceptor('avatar', { // 'avatar' matches the field name sent from Flutter
    storage: diskStorage({
      destination: './uploads', 
      filename: (req, file, callback) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = extname(file.originalname);
        callback(null, `profile-${uniqueSuffix}${ext}`);
      },
    }),
  }))
  async updateProfile(
    @Request() req, 
    @Body() body: any, 
    @UploadedFile() file: Express.Multer.File
  ) {
    const userId = req.user.id; 
    
    // Map Frontend fields to Entity columns
    const updateData: any = {
      name: body.name,
      phone_number: body.phone,
      email: body.email,
    };

    // Handle Image Upload
    if (file) {
      updateData.profile_picture = `uploads/${file.filename}`;
    }

    // Update using your existing service method
    // Note: Ensure your UserService.update method handles Partial<User>
   try {
      await this.userService.update(userId, updateData);
      return { message: 'Profile updated successfully', user: updateData };
    } catch (error) {
      // Handle duplicate email error
      if (error.code === 'ER_DUP_ENTRY') { 
        throw new Error('Email or Phone already in use');
      }
      throw error;
    }
  }
}