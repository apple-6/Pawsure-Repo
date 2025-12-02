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
exports.PetController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const pet_service_1 = require("./pet.service");
const create_pet_dto_1 = require("./dto/create-pet.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let PetController = class PetController {
    petService;
    constructor(petService) {
        this.petService = petService;
    }
    async getMyPets(req) {
        console.log('🔍 JWT User from token:', req.user);
        const userId = req.user.id;
        console.log('🔍 Fetching pets for user ID:', userId);
        const pets = await this.petService.findByOwner(userId);
        console.log('📦 Found', pets.length, 'pets for user', userId);
        return pets;
    }
    async debugAllPets() {
        console.log('🐛 Debug endpoint called - fetching all pets');
        const allPets = await this.petService.findAll();
        console.log('🐛 Total pets in database:', allPets.length);
        return {
            total: allPets.length,
            pets: allPets.map(p => ({
                id: p.id,
                name: p.name,
                ownerId: p.ownerId,
                species: p.species,
                breed: p.breed
            }))
        };
    }
    async getPetsByOwnerParam(ownerId) {
        console.log('🔍 Fetching pets for ownerId:', ownerId);
        return this.petService.findByOwner(Number(ownerId));
    }
    async createPet(createPetDto, file, req) {
        console.log('➕ Creating pet for user:', req.user.id);
        const ownerId = req.user.id;
        createPetDto.ownerId = ownerId;
        if (file) {
            createPetDto.photoUrl = `https://your-supabase-url/storage/photos/${file.filename}`;
        }
        return this.petService.create(createPetDto);
    }
};
exports.PetController = PetController;
__decorate([
    (0, common_1.Get)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "getMyPets", null);
__decorate([
    (0, common_1.Get)('debug'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], PetController.prototype, "debugAllPets", null);
__decorate([
    (0, common_1.Get)('owner/:ownerId'),
    __param(0, (0, common_1.Param)('ownerId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "getPetsByOwnerParam", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('photo')),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.UploadedFile)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_pet_dto_1.CreatePetDto, Object, Object]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "createPet", null);
exports.PetController = PetController = __decorate([
    (0, common_1.Controller)('pets'),
    __metadata("design:paramtypes", [pet_service_1.PetService])
], PetController);
//# sourceMappingURL=pet.controller.js.map