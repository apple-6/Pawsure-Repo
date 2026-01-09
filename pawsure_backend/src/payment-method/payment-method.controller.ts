// pawsure_backend/src/payment-method/payment-method.controller.ts
import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
  Request,
} from '@nestjs/common';
import { PaymentMethodService } from './payment-method.service';
import { CreatePaymentMethodDto } from './dto/create-payment-method.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('payment-methods')
@UseGuards(JwtAuthGuard)
export class PaymentMethodController {
  constructor(private readonly paymentMethodService: PaymentMethodService) {}

  @Post()
  async create(@Request() req, @Body() dto: CreatePaymentMethodDto) {
    return await this.paymentMethodService.create(req.user.id, dto);
  }

  @Get()
  async findAll(@Request() req) {
    return await this.paymentMethodService.findAllByUser(req.user.id);
  }

  @Get('default')
  async getDefault(@Request() req) {
    return await this.paymentMethodService.getDefaultMethod(req.user.id);
  }

  @Patch(':id/default')
  async setDefault(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return await this.paymentMethodService.setDefault(id, req.user.id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    await this.paymentMethodService.remove(id, req.user.id);
    return { message: 'Payment method deleted successfully' };
  }
}

