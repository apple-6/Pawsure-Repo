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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetController = void 0;
const common_1 = require("@nestjs/common");
const pet_service_1 = require("./pet.service");
let PetController = class PetController {
    petService;
    constructor(petService) {
        this.petService = petService;
    }
    findAll() {
        return this.petService.findAll();
    }
};
exports.PetController = PetController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PetController.prototype, "findAll", null);
exports.PetController = PetController = __decorate([
    (0, common_1.Controller)('pets'),
    __metadata("design:paramtypes", [pet_service_1.PetService])
], PetController);
//# sourceMappingURL=pet.controller.js.map