import { AiService } from './ai.service';
export declare class AiController {
    private readonly aiService;
    constructor(aiService: AiService);
    analyzePhoto(file: Express.Multer.File): Promise<{
        analysis_id: string;
        results: {
            description: string | null | undefined;
            score: number | null | undefined;
        }[];
        suggestion: string;
    }>;
}
