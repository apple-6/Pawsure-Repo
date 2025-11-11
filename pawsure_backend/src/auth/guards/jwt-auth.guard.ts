// src/auth/guards/jwt-auth.guard.ts
import { 
  Injectable, 
  ExecutionContext, 
  UnauthorizedException 
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err, user, info, context) {
    // This will show you exactly what's wrong with the JWT
    if (err || !user) {
      console.error('JWT Authentication Failed');
      console.error('Error:', err);
      console.error('Info:', info);
      console.error('User:', user);
      
      throw err || new UnauthorizedException(
        info?.message || 'Invalid or missing authentication token'
      );
    }
    return user;
  }
}