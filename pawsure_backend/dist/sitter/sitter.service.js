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
exports.SitterService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const sitter_entity_1 = require("./sitter.entity");
const user_entity_1 = require("../user/user.entity");
const user_service_1 = require("../user/user.service");
let SitterService = class SitterService {
    sitterRepository;
    userService;
    userRepository;
    constructor(sitterRepository, userService, userRepository) {
        this.sitterRepository = sitterRepository;
        this.userService = userService;
        this.userRepository = userRepository;
    }
    async create(createSitterDto, userId) {
        const user = await this.userService.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const existingSitter = await this.sitterRepository.findOne({
            where: { userId },
        });
        if (existingSitter) {
            throw new common_1.ConflictException('User already has a sitter profile');
        }
        const sitter = this.sitterRepository.create({
            ...createSitterDto,
            userId,
        });
        const savedSitter = await this.sitterRepository.save(sitter);
        await this.userService.updateUserRole(userId, 'sitter');
        return savedSitter;
    }
    async findAll(minRating) {
        const query = this.sitterRepository
            .createQueryBuilder('sitter')
            .leftJoinAndSelect('sitter.user', 'user')
            .where('sitter.deleted_at IS NULL')
            .orderBy('sitter.rating', 'DESC');
        if (minRating) {
            query.where('sitter.rating >= :minRating', { minRating });
        }
        return await query.getMany();
    }
    async findOne(id) {
        const sitter = await this.sitterRepository.findOne({
            where: { id },
            withDeleted: false,
            relations: ['user', 'reviews', 'bookings'],
        });
        if (!sitter) {
            throw new common_1.NotFoundException(`Sitter with ID ${id} not found`);
        }
        return sitter;
    }
    async findByUserId(userId) {
        return await this.sitterRepository.findOne({
            where: { userId, deleted_at: (0, typeorm_2.IsNull)() },
            relations: ['user'],
        });
    }
    async update(id, updateSitterDto, userId) {
        const sitter = await this.findOne(id);
        if (sitter.userId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own sitter profile');
        }
        if (updateSitterDto.phoneNumber) {
            const user = await this.userRepository.findOne({ where: { id: userId } });
            if (user) {
                user.phone_number = updateSitterDto.phoneNumber;
                await this.userRepository.save(user);
            }
            delete updateSitterDto.phoneNumber;
        }
        Object.assign(sitter, updateSitterDto);
        await this.sitterRepository.save(sitter);
        const freshSitter = await this.sitterRepository.findOne({
            where: { id },
            relations: ['user', 'reviews', 'bookings'],
        });
        if (!freshSitter) {
            throw new common_1.NotFoundException(`Sitter profile with ID ${id} not found after update.`);
        }
        return freshSitter;
    }
    async remove(id, userId) {
        const sitter = await this.findOne(id);
        if (sitter.userId !== userId) {
            throw new common_1.ForbiddenException('You can only delete your own sitter profile');
        }
        await this.sitterRepository.remove(sitter);
    }
    async updateRating(id) {
        const sitter = await this.sitterRepository.findOne({
            where: { id },
            relations: ['reviews'],
        });
        if (!sitter) {
            throw new common_1.NotFoundException(`Sitter with ID ${id} not found`);
        }
        if (sitter.reviews && sitter.reviews.length > 0) {
            const totalRating = sitter.reviews.reduce((sum, review) => sum + review.rating, 0);
            sitter.rating = totalRating / sitter.reviews.length;
            sitter.reviews_count = sitter.reviews.length;
        }
        else {
            sitter.rating = 0;
            sitter.reviews_count = 0;
        }
        return await this.sitterRepository.save(sitter);
    }
    async searchByAvailability(date) {
        return await this.sitterRepository
            .createQueryBuilder('sitter')
            .leftJoinAndSelect('sitter.user', 'user')
            .where(':date = ANY(sitter.available_dates)', { date })
            .orderBy('sitter.rating', 'DESC')
            .getMany();
    }
};
exports.SitterService = SitterService;
exports.SitterService = SitterService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(sitter_entity_1.Sitter)),
    __param(2, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        user_service_1.UserService,
        typeorm_2.Repository])
], SitterService);
//# sourceMappingURL=sitter.service.js.map