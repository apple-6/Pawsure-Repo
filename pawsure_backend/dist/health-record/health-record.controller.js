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
exports.HealthRecordController = void 0;
const common_1 = require("@nestjs/common");
const health_record_service_1 = require("./health-record.service");
const create_health_record_dto_1 = require("./dto/create-health-record.dto");
const update_health_record_dto_1 = require("./dto/update-health-record.dto");
let HealthRecordController = class HealthRecordController {
    healthRecordService;
    constructor(healthRecordService) {
        this.healthRecordService = healthRecordService;
    }
    create(petId, createHealthRecordDto) {
        return this.healthRecordService.create(petId, createHealthRecordDto);
    }
    findAllForPet(petId) {
        return this.healthRecordService.findAllForPet(petId);
    }
    update(id, updateHealthRecordDto) {
        return this.healthRecordService.update(id, updateHealthRecordDto);
    }
    async remove(id) {
        await this.healthRecordService.remove(id);
        return { message: 'Health record deleted successfully' };
    }
};
exports.HealthRecordController = HealthRecordController;
__decorate([
    (0, common_1.Post)('/pets/:petId/health-records'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ transform: true })),
    __param(0, (0, common_1.Param)('petId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, create_health_record_dto_1.CreateHealthRecordDto]),
    __metadata("design:returntype", void 0)
], HealthRecordController.prototype, "create", null);
__decorate([
    (0, common_1.Get)('/pets/:petId/health-records'),
    __param(0, (0, common_1.Param)('petId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], HealthRecordController.prototype, "findAllForPet", null);
__decorate([
    (0, common_1.Put)('/health-records/:id'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ transform: true })),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_health_record_dto_1.UpdateHealthRecordDto]),
    __metadata("design:returntype", void 0)
], HealthRecordController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)('/health-records/:id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], HealthRecordController.prototype, "remove", null);
exports.HealthRecordController = HealthRecordController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [health_record_service_1.HealthRecordService])
], HealthRecordController);
//# sourceMappingURL=health-record.controller.js.map