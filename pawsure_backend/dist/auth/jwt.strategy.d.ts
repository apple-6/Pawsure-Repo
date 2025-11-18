import { Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from 'src/user/user.service';
declare const JwtStrategy_base: new (...args: any[]) => Strategy;
export declare class JwtStrategy extends JwtStrategy_base {
    private readonly configService;
    private readonly userService;
    constructor(configService: ConfigService, userService: UserService);
    validate(payload: {
        sub: number;
        email: string;
    }): Promise<import("../user/user.entity").User>;
}
export {};
