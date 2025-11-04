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
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret-key-12345',
    });
    console.log('JWT Secret in strategy:', configService.get<string>('JWT_SECRET')); // Debug log
  }

  async validate(payload: { sub: number; email: string }) {
    console.log('JWT Payload:', payload); // Debug log
    const user = await this.userService.findById(payload.sub);
    console.log('User found:', user ? 'Yes' : 'No'); // Debug log
    if (!user) {
      throw new UnauthorizedException();
    }
    return user;
  }
}