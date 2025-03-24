import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

@Injectable()
export class WalletService {
  constructor(private prisma: PrismaService) {}

  // Método temporal para simular wallet
  private async getWallets(userId: string) {
    // Simulación de billeteras en memoria
    return [
      {
        id: '1',
        name: 'Principal',
        balance: 1000,
        currency: 'MXN',
        isDefault: true,
        userId,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
  }

  async findAll(userId: string) {
    // Implementación temporal hasta que el modelo se actualice
    return this.getWallets(userId);
  }

  async findOne(id: string, userId: string) {
    const wallets = await this.getWallets(userId);
    return wallets.find(w => w.id === id) || null;
  }

  async create(data: any, userId: string) {
    // Implementación temporal
    return {
      id: Date.now().toString(),
      ...data,
      userId,
      createdAt: new Date(),
      updatedAt: new Date()
    };
  }

  async update(id: string, data: any, userId: string) {
    const wallet = await this.findOne(id, userId);
    if (!wallet) throw new Error('Wallet not found');
    
    return {
      ...wallet,
      ...data,
      updatedAt: new Date()
    };
  }

  async remove(id: string, userId: string) {
    const wallet = await this.findOne(id, userId);
    if (!wallet) throw new Error('Wallet not found');
    
    return wallet;
  }

  async getBalance(userId: string) {
    const wallets = await this.getWallets(userId);
    return wallets.map(w => ({
      id: w.id,
      name: w.name,
      balance: w.balance,
      currency: w.currency
    }));
  }
} 