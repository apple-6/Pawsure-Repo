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
const create_sitter_dto_1 = require("./dto/create-sitter.dto");
const update_sitter_dto_1 = require("./dto/update-sitter.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let SitterController = class SitterController {
    sitterService;
    constructor(sitterService) {
        this.sitterService = sitterService;
    }
    async create(createSitterDto, req) {
        return await this.sitterService.create(createSitterDto, req.user.id);
    }
    async findAll(minRating) {
        let parsed;
        if (minRating !== undefined && minRating !== null && minRating.trim() !== '') {
            parsed = Number(minRating);
            if (Number.isNaN(parsed)) {
                throw new common_1.BadRequestException('minRating must be a numeric value');
            }
        }
        return await this.sitterService.findAll(parsed);
    }
    async searchByAvailability(date) {
        return await this.sitterService.searchByAvailability(date);
    }
    async getMyProfile(req) {
        return await this.sitterService.findByUserId(req.user.id);
    }
    async findOne(id) {
        return await this.sitterService.findOne(id);
    }
    async update(id, updateSitterDto, req) {
        return await this.sitterService.update(id, updateSitterDto, req.user.id);
    }
    async remove(id, req) {
        await this.sitterService.remove(id, req.user.id);
    }
};
exports.SitterController = SitterController;
__decorate([
    (0, common_1.Post)('setup'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_sitter_dto_1.CreateSitterDto, Object]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('minRating')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)('date')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "searchByAvailability", null);
__decorate([
    (0, common_1.Get)('my-profile'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "getMyProfile", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_sitter_dto_1.UpdateSitterDto, Object]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", Promise)
], SitterController.prototype, "remove", null);
exports.SitterController = SitterController = __decorate([
    (0, common_1.Controller)('sitters'),
    __metadata("design:paramtypes", [sitter_service_1.SitterService])
], SitterController);
//# sourceMappingURL=sitter.controller.js.map