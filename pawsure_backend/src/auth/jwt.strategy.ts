import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from 'src/user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly userService: UserService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'my-super-secret-jwt-key-12345',
    });
    console.log('✅ JWT Strategy initialized');
    console.log('🔑 JWT Secret:', configService.get<string>('JWT_SECRET'));
  }

  async validate(payload: { sub: number; email: string; role?: string }) {
    console.log('🔐 Validating JWT payload:', payload);
    
    const user = await this.userService.findById(payload.sub);
    
    if (!user) {
      console.log('❌ User not found for ID:', payload.sub);
      throw new UnauthorizedException('User not found');
    }
    
    console.log('✅ User validated:', { id: user.id, email: user.email, role: user.role });
    
    // Return the user object - this becomes req.user
    return user;
  }
}