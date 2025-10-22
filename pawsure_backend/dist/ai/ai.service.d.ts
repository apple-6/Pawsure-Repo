export declare class AiService {
    private readonly client;
    constructor();
    analyzeImage(imageBuffer: Buffer): Promise<{
        analysis_id: string;
        results: {
            description: string | null | undefined;
            score: number | null | undefined;
        }[];
        suggestion: string;
    }>;
}
