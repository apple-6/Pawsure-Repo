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
    // 1. Resize image to 224x224 (required for YOLOv11)
    const { data } = await sharp(imageBuffer)
      .resize(224, 224)
      .toColorspace('srgb')
      .raw()
      .toBuffer({ resolveWithObject: true });

    // 2. Normalize pixels (0-255 -> 0-1)
    const floatData = new Float32Array(data.length);
    for (let i = 0; i < data.length; i++) {
      floatData[i] = data[i] / 255.0;
    }

    // 3. Create Tensor [Batch, Channels, Height, Width]
    const tensor = new ort.Tensor('float32', floatData, [1, 3, 224, 224]);

    // 4. Run Model
    const output = await this.session.run({ images: tensor });
    const probabilities = output.output0.data as Float32Array;

    // 5. Get result
    const maxIdx = probabilities.indexOf(Math.max(...probabilities));

    return {
      prediction: this.labels[maxIdx],
      confidence: (probabilities[maxIdx] * 100).toFixed(2) + '%',
      allScores: probabilities // Optional: see scores for all 4 classes
    };
  }
}