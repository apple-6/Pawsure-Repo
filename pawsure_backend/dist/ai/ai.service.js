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
exports.AiService = void 0;
const common_1 = require("@nestjs/common");
const vision_1 = require("@google-cloud/vision");
const path_1 = require("path");
let AiService = class AiService {
    client;
    constructor() {
        this.client = new vision_1.ImageAnnotatorClient({
            keyFilename: (0, path_1.join)(process.cwd(), 'google-credentials.json'),
        });
    }
    async analyzeImage(imageBuffer) {
        const [result] = await this.client.labelDetection(imageBuffer);
        const labels = result.labelAnnotations;
        console.log('Google Vision API results:');
        console.log(labels);
        const processedResults = (labels || []).map((label) => ({
            description: label.description,
            score: label.score,
        }));
        return {
            analysis_id: `ai_${new Date().getTime()}`,
            results: processedResults,
            suggestion: 'Analysis complete. Further logic needed.',
        };
    }
};
exports.AiService = AiService;
exports.AiService = AiService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], AiService);
//# sourceMappingURL=ai.service.js.map