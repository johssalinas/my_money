import { Module } from '@nestjs/common';
import { WalletController } from './controllers/wallet.controller';
import { WalletService } from './services/wallet.service';
import { PrismaService } from '../../prisma/prisma.service';

@Module({
  controllers: [
    WalletController,
  ],
  providers: [
    WalletService,
    PrismaService,
  ],
  exports: [
    WalletService,
  ],
})
export class FinancesModule {} 