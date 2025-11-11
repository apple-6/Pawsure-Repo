import { PartialType } from '@nestjs/mapped-types';
import { CreateSitterDto } from './create-sitter.dto';

export class UpdateSitterDto extends PartialType(CreateSitterDto) {}
