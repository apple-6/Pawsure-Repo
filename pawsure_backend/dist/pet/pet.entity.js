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
exports.Pet = void 0;
const activity_log_entity_1 = require("../activity-log/activity-log.entity");
const booking_entity_1 = require("../booking/booking.entity");
const health_record_entity_1 = require("../health-record/health-record.entity");
const user_entity_1 = require("../user/user.entity");
const typeorm_1 = require("typeorm");
let Pet = class Pet {
    id;
    name;
    species;
    breed;
    dob;
    weight;
    allergies;
    vaccination_dates;
    last_vet_visit;
    mood_rating;
    streak;
    created_at;
    updated_at;
    owner;
    bookings;
    activityLogs;
    healthRecords;
};
exports.Pet = Pet;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Pet.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Pet.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Pet.prototype, "species", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Pet.prototype, "breed", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date' }),
    __metadata("design:type", String)
], Pet.prototype, "dob", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'float', nullable: true }),
    __metadata("design:type", Number)
], Pet.prototype, "weight", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Pet.prototype, "allergies", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', array: true, nullable: true }),
    __metadata("design:type", Array)
], Pet.prototype, "vaccination_dates", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', nullable: true }),
    __metadata("design:type", String)
], Pet.prototype, "last_vet_visit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'float', nullable: true }),
    __metadata("design:type", Number)
], Pet.prototype, "mood_rating", void 0);
__decorate([
    (0, typeorm_1.Column)({ default: 0 }),
    __metadata("design:type", Number)
], Pet.prototype, "streak", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Pet.prototype, "created_at", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], Pet.prototype, "updated_at", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.pets),
    __metadata("design:type", user_entity_1.User)
], Pet.prototype, "owner", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => booking_entity_1.Booking, (booking) => booking.pet),
    __metadata("design:type", Array)
], Pet.prototype, "bookings", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => activity_log_entity_1.ActivityLog, (log) => log.pet),
    __metadata("design:type", Array)
], Pet.prototype, "activityLogs", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => health_record_entity_1.HealthRecord, (record) => record.pet),
    __metadata("design:type", Array)
], Pet.prototype, "healthRecords", void 0);
exports.Pet = Pet = __decorate([
    (0, typeorm_1.Entity)('pets')
], Pet);
//# sourceMappingURL=pet.entity.js.map