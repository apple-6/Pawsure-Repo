import { Injectable, OnModuleInit } from '@nestjs/common';
import * as ort from 'onnxruntime-node';
import sharp = require('sharp');
import { join } from 'path';

@Injectable()
export class AiService implements OnModuleInit {
  private session: ort.InferenceSession;
  
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
}