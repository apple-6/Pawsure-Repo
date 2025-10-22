import { Injectable } from '@nestjs/common';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import { join } from 'path'; // <-- 1. IMPORT THIS

@Injectable()
export class AiService {
  private readonly client: ImageAnnotatorClient;

  // 2. INJECT 'ConfigService' HERE
  constructor() {
    // 3. Point directly to your new JSON key file
    this.client = new ImageAnnotatorClient({
      keyFilename: join(process.cwd(), 'google-credentials.json'),
    });
  }

  // ... rest of your service ...
  async analyzeImage(imageBuffer: Buffer) {
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
}
