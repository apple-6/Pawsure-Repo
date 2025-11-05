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
exports.HealthRecordService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const health_record_entity_1 = require("./health-record.entity");
const pet_entity_1 = require("../pet/pet.entity");
let HealthRecordService = class HealthRecordService {
    healthRecordRepository;
    petRepository;
    constructor(healthRecordRepository, petRepository) {
        this.healthRecordRepository = healthRecordRepository;
        this.petRepository = petRepository;
    }
    async create(petId, dto) {
        const pet = await this.petRepository.findOne({ where: { id: petId } });
        if (!pet) {
            throw new common_1.NotFoundException(`Pet with ID ${petId} not found`);
        }
        const record = this.healthRecordRepository.create({
            record_type: dto.record_type,
            record_date: new Date(dto.record_date).toISOString().slice(0, 10),
            description: dto.description ?? '',
            pet,
            clinic: dto.clinic,
            nextDueDate: dto.nextDueDate,
        });
        const savedRecord = await this.healthRecordRepository.save(record);
        const reloadedRecord = await this.healthRecordRepository.findOne({
            where: { id: savedRecord.id },
        });
        if (!reloadedRecord) {
            throw new common_1.NotFoundException('Failed to reload saved health record');
        }
        return reloadedRecord;
    }
    async findAllForPet(petId) {
        const pet = await this.petRepository.findOne({ where: { id: petId } });
        if (!pet) {
            throw new common_1.NotFoundException(`Pet with ID ${petId} not found`);
        }
        return this.healthRecordRepository.find({
            where: { pet: { id: petId } },
            order: { record_date: 'DESC' },
        });
    }
};
exports.HealthRecordService = HealthRecordService;
exports.HealthRecordService = HealthRecordService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(health_record_entity_1.HealthRecord)),
    __param(1, (0, typeorm_1.InjectRepository)(pet_entity_1.Pet)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], HealthRecordService);
//# sourceMappingURL=health-record.service.js.map