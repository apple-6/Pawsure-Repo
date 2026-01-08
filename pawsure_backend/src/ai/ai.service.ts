import { Injectable, OnModuleInit } from '@nestjs/common';
import * as ort from 'onnxruntime-node';
import sharp = require('sharp');
import { join } from 'path';
import { InjectRepository } from '@nestjs/typeorm';
import { AiScan } from './ai-scan.entity';
import { Repository } from 'typeorm';

@Injectable()
export class AiService implements OnModuleInit {
  private session: ort.InferenceSession;

  constructor(
    @InjectRepository(AiScan)
    private readonly aiScanRepository: Repository<AiScan>, // 'private' makes it available as 'this.aiScanRepository'
  ) {}
  
  // These must match your YOLO model's training order exactly
  private readonly labels = {
    0: 'Diarrhea',
    1: 'Lack-of-nutrition',
    2: 'Normal',
    3: 'Soft-Poop',
  };

  async onModuleInit() {
    try {
      // Make sure your best.onnx is in src/assets/models/
      const modelPath = join(process.cwd(), 'src/assets/models/best.onnx');
      this.session = await ort.InferenceSession.create(modelPath);
      console.log('✅ PawSure AI Model Loaded Successfully');
    } catch (e) {
      console.error('❌ Failed to load AI model:', e);
    }
  }

  // 2. Add the method to save the scan result to the database
  async saveScan(petId: number, result: string, confidence: string) {
    const scan = this.aiScanRepository.create({
      type: 'Stool Analysis',
      result: result,
      // Clean the confidence string (e.g., "99.60%" -> 99.60)
      confidence: parseFloat(confidence.replace('%', '')),
      pet: { id: petId } as any, // Link to the pet via ID
    });
    
    return await this.aiScanRepository.save(scan);
  }

  async classify(imageBuffer: Buffer) {
    try {
      // 1. Resize and ensure exactly 3 channels (RGB)
      const { data } = await sharp(imageBuffer)
        .resize(224, 224, { fit: 'fill' })
        .removeAlpha() // Critical: ensures data length is 224 * 224 * 3
        .toColorspace('srgb')
        .raw()
        .toBuffer({ resolveWithObject: true });

      const rows = 224;
      const cols = 224;
      const area = rows * cols;
      
      // 2. Prepare CHW (Planar) float32 array
      // Current 'data' is [R,G,B, R,G,B...] (Interleaved)
      // YOLO wants [R,R,R... G,G,G... B,B,B...] (Planar)
      const float32Data = new Float32Array(3 * area);

      for (let i = 0; i < area; i++) {
        const r = data[i * 3 + 0] / 255.0;
        const g = data[i * 3 + 1] / 255.0;
        const b = data[i * 3 + 2] / 255.0;

        float32Data[i] = r;              // Red channel
        float32Data[i + area] = g;       // Green channel
        float32Data[i + 2 * area] = b;   // Blue channel
      }

      // 3. Create Tensor
      const tensor = new ort.Tensor('float32', float32Data, [1, 3, 224, 224]);

      // 4. Run Model
      const output = await this.session.run({ images: tensor });
      
      // Handle potential variation in output key name (usually output0)
      const outputKey = Object.keys(output)[0];
      const probabilities = Array.from(output[outputKey].data as Float32Array);

      // 5. Get result
      const maxIdx = probabilities.indexOf(Math.max(...probabilities));

      console.log('Model Raw Probabilities:', probabilities); // Debugging line

      return {
        prediction: this.labels[maxIdx],
        confidence: (probabilities[maxIdx] * 100).toFixed(2) + '%',
        allScores: probabilities 
      };
    } catch (error) {
      console.error('Classification error:', error);
      throw error;
    }
  }

  async getScanHistory(petId: number): Promise<AiScan[]> {
    return await this.aiScanRepository.find({
      where: { pet: { id: petId } },
      order: { scannedAt: 'DESC' }, // Show newest scans first
    });
  }

  // Inside the AiService class
  async deleteScan(id: number): Promise<void> {
    // .delete(id) is a TypeORM command that removes the record from Supabase
    await this.aiScanRepository.delete(id);
  }
}