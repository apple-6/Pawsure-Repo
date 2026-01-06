// pawsure_backend/src/payment-method/dto/create-payment-method.dto.ts
import { IsString, IsNotEmpty, Length, IsOptional, IsBoolean } from 'class-validator';

export class CreatePaymentMethodDto {
  @IsString()
  @IsNotEmpty()
  cardType: string; // 'visa', 'mastercard', 'amex'

  @IsString()
  @Length(4, 4)
  lastFourDigits: string;

  @IsString()
  @IsNotEmpty()
  cardholderName: string;

  @IsString()
  @Length(2, 2)
  expiryMonth: string;

  @IsString()
  @Length(4, 4)
  expiryYear: string;

  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;

  @IsString()
  @IsOptional()
  nickname?: string;
}

