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
exports.Sitter = exports.SitterStatus = void 0;
const typeorm_1 = require("typeorm");
const user_entity_1 = require("../user/user.entity");
const booking_entity_1 = require("../booking/booking.entity");
const review_entity_1 = require("../review/review.entity");
var SitterStatus;
(function (SitterStatus) {
    SitterStatus["PENDING"] = "pending";
    SitterStatus["APPROVED"] = "approved";
    SitterStatus["REJECTED"] = "rejected";
})(SitterStatus || (exports.SitterStatus = SitterStatus = {}));
let Sitter = class Sitter {
    id;
    bio;
    experience;
    photo_gallery;
    rating;
    reviews_count;
    available_dates;
    address;
    houseType;
    hasGarden;
    hasOtherPets;
    idDocumentUrl;
    ratePerNight;
    status;
    userId;
    user;
    bookings;
    reviews;
    created_at;
    updated_at;
    deleted_at;
};
exports.Sitter = Sitter;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Sitter.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "bio", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "experience", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "photo_gallery", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'double precision', default: 0 }),
    __metadata("design:type", Number)
], Sitter.prototype, "rating", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], Sitter.prototype, "reviews_count", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'simple-array', nullable: true }),
    __metadata("design:type", Array)
], Sitter.prototype, "available_dates", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "address", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "houseType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'boolean', default: false }),
    __metadata("design:type", Boolean)
], Sitter.prototype, "hasGarden", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'boolean', default: false }),
    __metadata("design:type", Boolean)
], Sitter.prototype, "hasOtherPets", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Sitter.prototype, "idDocumentUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'decimal', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], Sitter.prototype, "ratePerNight", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: SitterStatus,
        default: SitterStatus.PENDING,
        nullable: true,
    }),
    __metadata("design:type", String)
], Sitter.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ unique: true, nullable: true }),
    __metadata("design:type", Number)
], Sitter.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => user_entity_1.User, (user) => user.sitterProfile, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'userId' }),
    __metadata("design:type", user_entity_1.User)
], Sitter.prototype, "user", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => booking_entity_1.Booking, (booking) => booking.sitter),
    __metadata("design:type", Array)
], Sitter.prototype, "bookings", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => review_entity_1.Review, (review) => review.sitter),
    __metadata("design:type", Array)
], Sitter.prototype, "reviews", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Sitter.prototype, "created_at", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], Sitter.prototype, "updated_at", void 0);
__decorate([
    (0, typeorm_1.DeleteDateColumn)({
        type: 'timestamp',
        nullable: true,
        name: 'deleted_at'
    }),
    __metadata("design:type", Date)
], Sitter.prototype, "deleted_at", void 0);
exports.Sitter = Sitter = __decorate([
    (0, typeorm_1.Entity)('sitters')
], Sitter);
//# sourceMappingURL=sitter.entity.js.map