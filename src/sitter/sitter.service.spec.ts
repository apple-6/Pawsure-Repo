import { Test, TestingModule } from '@nestjs/testing';
import { SitterService } from './sitter.service';

describe('SitterService', () => {
  let service: SitterService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SitterService],
    }).compile();

    service = module.get<SitterService>(SitterService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
