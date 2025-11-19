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
exports.PetService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const pet_entity_1 = require("./pet.entity");
let PetService = class PetService {
    petRepository;
    constructor(petRepository) {
        this.petRepository = petRepository;
    }
    async create(createPetDto) {
        const pet = this.petRepository.create(createPetDto);
        return await this.petRepository.save(pet);
    }
    async findAll(ownerId) {
        if (ownerId) {
            return await this.petRepository.find({
                where: { ownerId },
                relations: ['owner'],
                order: { created_at: 'DESC' },
            });
        }
        return await this.petRepository.find({
            relations: ['owner'],
            order: { created_at: 'DESC' },
        });
    }
    async findOne(id) {
        const pet = await this.petRepository.findOne({
            where: { id },
            relations: ['owner', 'activityLogs', 'healthRecords'],
        });
        if (!pet) {
            throw new common_1.NotFoundException(`Pet with ID ${id} not found`);
        }
        return pet;
    }
    async findByOwner(ownerId) {
        return await this.petRepository.find({
            where: { ownerId },
            relations: ['owner'],
            order: { created_at: 'DESC' },
        });
    }
    async update(id, updatePetDto, userId) {
        const pet = await this.findOne(id);
        if (pet.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own pets');
        }
        Object.assign(pet, updatePetDto);
        return await this.petRepository.save(pet);
    }
    async remove(id, userId) {
        const pet = await this.findOne(id);
        if (pet.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only delete your own pets');
        }
        await this.petRepository.remove(pet);
    }
    async updateStreak(id, streak) {
        const pet = await this.findOne(id);
        pet.streak = streak;
        return await this.petRepository.save(pet);
    }
    async updateMoodRating(id, moodRating) {
        const pet = await this.findOne(id);
        pet.mood_rating = moodRating;
        return await this.petRepository.save(pet);
    }
};
exports.PetService = PetService;
exports.PetService = PetService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(pet_entity_1.Pet)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], PetService);
//# sourceMappingURL=pet.service.js.map