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
let PetController = class PetController {
    petService;
    constructor(petService) {
        this.petService = petService;
    }
    async createPet(createPetDto, file, req) {
        const ownerId = req.user?.id || 1;
        createPetDto.ownerId = ownerId;
        if (file) {
            createPetDto.photoUrl = `https://your-supabase-url/storage/photos/${file.filename}`;
        }
        return this.petService.createPet(createPetDto);
    }
    async getPetsByOwnerParam(ownerId) {
        return this.petService.findPetsByOwner(Number(ownerId));
    }
    async getPetsByOwnerQuery(ownerId) {
        if (!ownerId)
            return [];
        return this.petService.findPetsByOwner(Number(ownerId));
    }
};
exports.PetController = PetController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('photo')),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.UploadedFile)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_pet_dto_1.CreatePetDto, Object, Object]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "createPet", null);
__decorate([
    (0, common_1.Get)('owner/:ownerId'),
    __param(0, (0, common_1.Param)('ownerId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "getPetsByOwnerParam", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('ownerId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PetController.prototype, "getPetsByOwnerQuery", null);
exports.PetController = PetController = __decorate([
    (0, common_1.Controller)('pets'),
    __metadata("design:paramtypes", [pet_service_1.PetService])
], PetController);
//# sourceMappingURL=pet.controller.js.map