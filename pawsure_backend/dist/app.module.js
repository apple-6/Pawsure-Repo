"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const ai_module_1 = require("./ai/ai.module");
const user_module_1 = require("./user/user.module");
const pet_module_1 = require("./pet/pet.module");
const sitter_module_1 = require("./sitter/sitter.module");
const booking_module_1 = require("./booking/booking.module");
const payment_module_1 = require("./payment/payment.module");
const activity_log_module_1 = require("./activity-log/activity-log.module");
const health_record_module_1 = require("./health-record/health-record.module");
const review_module_1 = require("./review/review.module");
const notification_module_1 = require("./notification/notification.module");
const posts_module_1 = require("./posts/posts.module");
const comments_module_1 = require("./comments/comments.module");
const likes_module_1 = require("./likes/likes.module");
const role_module_1 = require("./role/role.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: (configService) => ({
                    type: 'postgres',
                    url: configService.get('DATABASE_URL'),
                    autoLoadEntities: true,
                    synchronize: true,
                    ssl: {
                        rejectUnauthorized: false
                    }
                }),
            }),
            ai_module_1.AiModule,
            ai_module_1.AiModule,
            user_module_1.UserModule,
            pet_module_1.PetModule,
            sitter_module_1.SitterModule,
            booking_module_1.BookingModule,
            payment_module_1.PaymentModule,
            activity_log_module_1.ActivityLogModule,
            health_record_module_1.HealthRecordModule,
            review_module_1.ReviewModule,
            notification_module_1.NotificationModule,
            posts_module_1.PostsModule,
            comments_module_1.CommentsModule,
            likes_module_1.LikesModule,
            role_module_1.RoleModule
        ],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map