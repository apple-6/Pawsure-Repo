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
const typeorm_1 = require("typeorm");
const user_entity_1 = require("../user/user.entity");
const activity_log_entity_1 = require("../activity-log/activity-log.entity");
const health_record_entity_1 = require("../health-record/health-record.entity");
const booking_entity_1 = require("../booking/booking.entity");
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
    photoUrl;
    ownerId;
    owner;
    activityLogs;
    healthRecords;
    bookings;
    created_at;
    updated_at;
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
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Pet.prototype, "species", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Pet.prototype, "breed", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', nullable: true }),
    __metadata("design:type", Date)
], Pet.prototype, "dob", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'double precision', nullable: true }),
    __metadata("design:type", Number)
], Pet.prototype, "weight", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Pet.prototype, "allergies", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'simple-array', nullable: true }),
    __metadata("design:type", Array)
], Pet.prototype, "vaccination_dates", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', nullable: true }),
    __metadata("design:type", Date)
], Pet.prototype, "last_vet_visit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'double precision', nullable: true }),
    __metadata("design:type", Number)
], Pet.prototype, "mood_rating", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], Pet.prototype, "streak", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Pet.prototype, "photoUrl", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], Pet.prototype, "ownerId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.pets),
    (0, typeorm_1.JoinColumn)({ name: 'ownerId' }),
    __metadata("design:type", user_entity_1.User)
], Pet.prototype, "owner", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => activity_log_entity_1.ActivityLog, (activityLog) => activityLog.pet),
    __metadata("design:type", Array)
], Pet.prototype, "activityLogs", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => health_record_entity_1.HealthRecord, (healthRecord) => healthRecord.pet),
    __metadata("design:type", Array)
], Pet.prototype, "healthRecords", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => booking_entity_1.Booking, (booking) => booking.pet),
    __metadata("design:type", Array)
], Pet.prototype, "bookings", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Pet.prototype, "created_at", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], Pet.prototype, "updated_at", void 0);
exports.Pet = Pet = __decorate([
    (0, typeorm_1.Entity)('pets')
], Pet);
//# sourceMappingURL=pet.entity.js.map