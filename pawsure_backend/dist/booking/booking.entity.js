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
exports.Booking = void 0;
const payment_entity_1 = require("../payment/payment.entity");
const pet_entity_1 = require("../pet/pet.entity");
const review_entity_1 = require("../review/review.entity");
const sitter_entity_1 = require("../sitter/sitter.entity");
const user_entity_1 = require("../user/user.entity");
const typeorm_1 = require("typeorm");
let Booking = class Booking {
    id;
    start_date;
    end_date;
    status;
    total_amount;
    created_at;
    updated_at;
    owner;
    sitter;
    pet;
    payment;
    reviews;
};
exports.Booking = Booking;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Booking.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date' }),
    __metadata("design:type", String)
], Booking.prototype, "start_date", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date' }),
    __metadata("design:type", String)
], Booking.prototype, "end_date", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Booking.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'float' }),
    __metadata("design:type", Number)
], Booking.prototype, "total_amount", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Booking.prototype, "created_at", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], Booking.prototype, "updated_at", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.bookings),
    __metadata("design:type", user_entity_1.User)
], Booking.prototype, "owner", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => sitter_entity_1.Sitter, (sitter) => sitter.bookings),
    __metadata("design:type", sitter_entity_1.Sitter)
], Booking.prototype, "sitter", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => pet_entity_1.Pet, (pet) => pet.bookings),
    __metadata("design:type", pet_entity_1.Pet)
], Booking.prototype, "pet", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => payment_entity_1.Payment, (payment) => payment.booking),
    __metadata("design:type", payment_entity_1.Payment)
], Booking.prototype, "payment", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => review_entity_1.Review, (review) => review.booking),
    __metadata("design:type", Array)
], Booking.prototype, "reviews", void 0);
exports.Booking = Booking = __decorate([
    (0, typeorm_1.Entity)('bookings')
], Booking);
//# sourceMappingURL=booking.entity.js.map