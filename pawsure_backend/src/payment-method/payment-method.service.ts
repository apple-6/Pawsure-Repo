// pawsure_backend/src/payment-method/payment-method.service.ts
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaymentMethod } from './payment-method.entity';
import { CreatePaymentMethodDto } from './dto/create-payment-method.dto';

@Injectable()
export class PaymentMethodService {
  constructor(
    @InjectRepository(PaymentMethod)
    private paymentMethodRepository: Repository<PaymentMethod>,
  ) {}

  async create(userId: number, dto: CreatePaymentMethodDto): Promise<PaymentMethod> {
    // If this is the first card or marked as default, set it as default
    const existingMethods = await this.findAllByUser(userId);
    
    const isDefault = dto.isDefault || existingMethods.length === 0;

    // If setting as default, unset other defaults
    if (isDefault && existingMethods.length > 0) {
      await this.paymentMethodRepository.update(
        { userId, isDefault: true },
        { isDefault: false },
      );
    }

    const paymentMethod = this.paymentMethodRepository.create({
      ...dto,
      userId,
      isDefault,
    });

    return await this.paymentMethodRepository.save(paymentMethod);
  }

  async findAllByUser(userId: number): Promise<PaymentMethod[]> {
    return await this.paymentMethodRepository.find({
      where: { userId },
      order: { isDefault: 'DESC', created_at: 'DESC' },
    });
  }

  async findOne(id: number): Promise<PaymentMethod> {
    const method = await this.paymentMethodRepository.findOne({
      where: { id },
    });

    if (!method) {
      throw new NotFoundException(`Payment method with ID ${id} not found`);
    }

    return method;
  }

  async setDefault(id: number, userId: number): Promise<PaymentMethod> {
    const method = await this.findOne(id);

    if (method.userId !== userId) {
      throw new ForbiddenException('You can only modify your own payment methods');
    }

    // Unset all other defaults for this user
    await this.paymentMethodRepository.update(
      { userId, isDefault: true },
      { isDefault: false },
    );

    // Set this one as default
    method.isDefault = true;
    return await this.paymentMethodRepository.save(method);
  }

  async remove(id: number, userId: number): Promise<void> {
    const method = await this.findOne(id);

    if (method.userId !== userId) {
      throw new ForbiddenException('You can only delete your own payment methods');
    }

    await this.paymentMethodRepository.remove(method);

    // If this was the default, set another one as default
    if (method.isDefault) {
      const remaining = await this.findAllByUser(userId);
      if (remaining.length > 0) {
        remaining[0].isDefault = true;
        await this.paymentMethodRepository.save(remaining[0]);
      }
    }
  }

  async getDefaultMethod(userId: number): Promise<PaymentMethod | null> {
    return await this.paymentMethodRepository.findOne({
      where: { userId, isDefault: true },
    });
  }
}

