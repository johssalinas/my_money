import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
} from '@nestjs/common';
import { WalletService } from '../services/wallet.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('wallets')
@UseGuards(JwtAuthGuard)
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post()
  create(@Body() createWalletDto: {
    name: string;
    balance?: number;
    currency?: string;
    icon?: string;
    color?: string;
    isDefault?: boolean;
  }, @Request() req) {
    return this.walletService.create(createWalletDto, req.user.id);
  }

  @Get()
  findAll(@Request() req) {
    return this.walletService.findAll(req.user.id);
  }

  @Get('balance')
  getBalance(@Request() req) {
    return this.walletService.getBalance(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.walletService.findOne(id, req.user.id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateWalletDto: {
      name?: string;
      balance?: number;
      currency?: string;
      icon?: string;
      color?: string;
      isDefault?: boolean;
    },
    @Request() req,
  ) {
    return this.walletService.update(id, updateWalletDto, req.user.id);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.walletService.remove(id, req.user.id);
  }
} 