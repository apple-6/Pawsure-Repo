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
const sitter_entity_1 = require("./sitter.entity");
const typeorm_2 = require("typeorm");
const user_service_1 = require("../user/user.service");
let SitterService = class SitterService {
    sitterRepository;
    userService;
    constructor(sitterRepository, userService) {
        this.sitterRepository = sitterRepository;
        this.userService = userService;
    }
    async setupProfile(userId, setupDto) {
        const user = await this.userService.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        let sitterProfile = await this.sitterRepository.findOne({
            where: { user: { id: userId } },
        });
        if (!sitterProfile) {
            sitterProfile = this.sitterRepository.create();
        }
        sitterProfile.address = setupDto.address;
        sitterProfile.phoneNumber = setupDto.phoneNumber;
        sitterProfile.houseType = setupDto.houseType;
        sitterProfile.hasGarden = setupDto.hasGarden;
        sitterProfile.hasOtherPets = setupDto.hasOtherPets;
        sitterProfile.idDocumentUrl = setupDto.idDocumentUrl;
        sitterProfile.bio = setupDto.bio;
        sitterProfile.ratePerNight = setupDto.ratePerNight;
        sitterProfile.user = user;
        await this.sitterRepository.save(sitterProfile);
        await this.userService.updateUserRole(user.id, 'sitter');
        return sitterProfile;
    }
};
exports.SitterService = SitterService;
exports.SitterService = SitterService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(sitter_entity_1.Sitter)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        user_service_1.UserService])
], SitterService);
//# sourceMappingURL=sitter.service.js.map