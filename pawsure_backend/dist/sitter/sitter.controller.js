"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SitterController = void 0;
const common_1 = require("@nestjs/common");
const sitter_service_1 = require("./sitter.service");
const sitter_setup_dto_1 = require("./dto/sitter-setup.dto");
const passport_1 = require("@nestjs/passport");
const get_user_decorator_1 = require("../auth/decorators/get-user.decorator");
const user_entity_1 = require("../user/user.entity");
let SitterController = class SitterController {
    sitterService;
    constructor(sitterService) {
        this.sitterService = sitterService;
    }
    setupProfile(setupDto, user) {
        return this.sitterService.setupProfile(user.id, setupDto);
    }
};
exports.SitterController = SitterController;
__decorate([
    (0, common_1.Post)('setup'),
    __param(0, (0, common_1.Body)(common_1.ValidationPipe)),
    __param(1, (0, get_user_decorator_1.GetUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [sitter_setup_dto_1.SitterSetupDto,
        user_entity_1.User]),
    __metadata("design:returntype", void 0)
], SitterController.prototype, "setupProfile", null);
exports.SitterController = SitterController = __decorate([
    (0, common_1.Controller)('sitter'),
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    __metadata("design:paramtypes", [sitter_service_1.SitterService])
], SitterController);
//# sourceMappingURL=sitter.controller.js.map