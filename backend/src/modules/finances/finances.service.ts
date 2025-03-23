import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Transaction, Wallet, FinanceCategory, Loan, Prisma, TransactionType, LoanType } from '@prisma/client';

@Injectable()
export class FinancesService {
  constructor(private prisma: PrismaService) {}

  // CARTERAS (WALLETS)
  async createWallet(data: Prisma.WalletCreateInput): Promise<Wallet> {
    return this.prisma.wallet.create({
      data,
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findWallets(ownerId: string): Promise<Wallet[]> {
    return this.prisma.wallet.findMany({
      where: {
        ownerId,
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findWalletById(id: string): Promise<Wallet> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { id },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!wallet) {
      throw new NotFoundException(`Cartera con ID ${id} no encontrada`);
    }

    return wallet;
  }

  async updateWallet(id: string, data: Prisma.WalletUpdateInput): Promise<Wallet> {
    try {
      return await this.prisma.wallet.update({
        where: { id },
        data,
        include: {
          owner: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Cartera con ID ${id} no encontrada`);
      }
      throw error;
    }
  }

  async deleteWallet(id: string): Promise<Wallet> {
    try {
      return await this.prisma.wallet.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Cartera con ID ${id} no encontrada`);
      }
      throw error;
    }
  }

  // TRANSACCIONES
  async createTransaction(data: Prisma.TransactionCreateInput): Promise<Transaction> {
    // Obtener la cartera
    const wallet = await this.prisma.wallet.findUnique({
      where: { id: data.wallet.connect.id },
    });

    if (!wallet) {
      throw new NotFoundException(`Cartera con ID ${data.wallet.connect.id} no encontrada`);
    }

    // Calcular el nuevo saldo de la cartera
    let newBalance = wallet.balance;
    
    if (data.type === TransactionType.INCOME || data.type === TransactionType.LOAN_RECEIVED) {
      newBalance += data.amount as number;
    } else if (data.type === TransactionType.EXPENSE || data.type === TransactionType.LOAN_GIVEN) {
      newBalance -= data.amount as number;
    }

    // Crear la transacción y actualizar el saldo de la cartera en una transacción
    return this.prisma.$transaction(async (prisma) => {
      const transaction = await prisma.transaction.create({
        data,
        include: {
          category: true,
          wallet: true,
          user: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });

      await prisma.wallet.update({
        where: { id: data.wallet.connect.id },
        data: { balance: newBalance },
      });

      return transaction;
    });
  }

  async findTransactions(params: {
    userId?: string;
    walletId?: string;
    categoryId?: string;
    type?: TransactionType;
    dateFrom?: Date;
    dateTo?: Date;
  }): Promise<Transaction[]> {
    const { userId, walletId, categoryId, type, dateFrom, dateTo } = params;
    
    const where: Prisma.TransactionWhereInput = {};
    
    if (userId) where.userId = userId;
    if (walletId) where.walletId = walletId;
    if (categoryId) where.categoryId = categoryId;
    if (type) where.type = type;
    
    if (dateFrom || dateTo) {
      where.date = {};
      if (dateFrom) where.date.gte = dateFrom;
      if (dateTo) where.date.lte = dateTo;
    }
    
    return this.prisma.transaction.findMany({
      where,
      include: {
        category: true,
        wallet: true,
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    });
  }

  async findTransactionById(id: string): Promise<Transaction> {
    const transaction = await this.prisma.transaction.findUnique({
      where: { id },
      include: {
        category: true,
        wallet: true,
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!transaction) {
      throw new NotFoundException(`Transacción con ID ${id} no encontrada`);
    }

    return transaction;
  }

  async deleteTransaction(id: string): Promise<Transaction> {
    // Primero obtener la transacción para saber su monto y tipo
    const transaction = await this.prisma.transaction.findUnique({
      where: { id },
      include: { wallet: true },
    });

    if (!transaction) {
      throw new NotFoundException(`Transacción con ID ${id} no encontrada`);
    }

    // Calcular el nuevo saldo de la cartera
    let newBalance = transaction.wallet.balance;
    
    if (transaction.type === TransactionType.INCOME || transaction.type === TransactionType.LOAN_RECEIVED) {
      newBalance -= transaction.amount;
    } else if (transaction.type === TransactionType.EXPENSE || transaction.type === TransactionType.LOAN_GIVEN) {
      newBalance += transaction.amount;
    }

    // Eliminar la transacción y actualizar el saldo de la cartera en una transacción
    return this.prisma.$transaction(async (prisma) => {
      const deletedTransaction = await prisma.transaction.delete({
        where: { id },
        include: {
          category: true,
          wallet: true,
          user: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });

      await prisma.wallet.update({
        where: { id: transaction.walletId },
        data: { balance: newBalance },
      });

      return deletedTransaction;
    });
  }

  // CATEGORÍAS FINANCIERAS
  async createCategory(data: Prisma.FinanceCategoryCreateInput): Promise<FinanceCategory> {
    return this.prisma.financeCategory.create({
      data,
    });
  }

  async findCategories(type?: TransactionType): Promise<FinanceCategory[]> {
    const where: Prisma.FinanceCategoryWhereInput = {};
    
    if (type) {
      where.type = type;
    }
    
    return this.prisma.financeCategory.findMany({
      where,
    });
  }

  async findCategoryById(id: string): Promise<FinanceCategory> {
    const category = await this.prisma.financeCategory.findUnique({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
    }

    return category;
  }

  async updateCategory(id: string, data: Prisma.FinanceCategoryUpdateInput): Promise<FinanceCategory> {
    try {
      return await this.prisma.financeCategory.update({
        where: { id },
        data,
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
      }
      throw error;
    }
  }

  async deleteCategory(id: string): Promise<FinanceCategory> {
    try {
      return await this.prisma.financeCategory.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
      }
      throw error;
    }
  }

  // PRÉSTAMOS
  async createLoan(data: Prisma.LoanCreateInput): Promise<Loan> {
    return this.prisma.loan.create({
      data,
    });
  }

  async findLoans(type?: LoanType, isPaid?: boolean): Promise<Loan[]> {
    const where: Prisma.LoanWhereInput = {};
    
    if (type) {
      where.type = type;
    }
    
    if (isPaid !== undefined) {
      where.isPaid = isPaid;
    }
    
    return this.prisma.loan.findMany({
      where,
      orderBy: {
        date: 'desc',
      },
    });
  }

  async findLoanById(id: string): Promise<Loan> {
    const loan = await this.prisma.loan.findUnique({
      where: { id },
    });

    if (!loan) {
      throw new NotFoundException(`Préstamo con ID ${id} no encontrado`);
    }

    return loan;
  }

  async updateLoan(id: string, data: Prisma.LoanUpdateInput): Promise<Loan> {
    try {
      return await this.prisma.loan.update({
        where: { id },
        data,
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Préstamo con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async markLoanAsPaid(id: string): Promise<Loan> {
    return this.updateLoan(id, { isPaid: true });
  }

  async deleteLoan(id: string): Promise<Loan> {
    try {
      return await this.prisma.loan.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Préstamo con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  // ESTADÍSTICAS Y REPORTES
  async getMonthlyBalance(userId: string, year: number, month: number): Promise<any> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0); // Último día del mes
    
    const transactions = await this.findTransactions({
      userId,
      dateFrom: startDate,
      dateTo: endDate,
    });
    
    let income = 0;
    let expense = 0;
    
    transactions.forEach(transaction => {
      if (transaction.type === TransactionType.INCOME || transaction.type === TransactionType.LOAN_RECEIVED) {
        income += transaction.amount;
      } else if (transaction.type === TransactionType.EXPENSE || transaction.type === TransactionType.LOAN_GIVEN) {
        expense += transaction.amount;
      }
    });
    
    return {
      income,
      expense,
      balance: income - expense,
      transactionCount: transactions.length,
      period: {
        year,
        month,
        startDate,
        endDate,
      },
    };
  }

  async getCategoryDistribution(userId: string, type: TransactionType, dateFrom?: Date, dateTo?: Date): Promise<any> {
    const transactions = await this.findTransactions({
      userId,
      type,
      dateFrom,
      dateTo,
    });
    
    // Crear un mapa para almacenar las categorías por ID
    const categories = {};
    
    // Para cada transacción, agrupar por categoría
    for (const transaction of transactions) {
      const categoryId = transaction.categoryId;
      
      // Si la categoría no existe en nuestro mapa, obtenerla de la base de datos
      if (!categories[categoryId]) {
        // Obtener la categoría de la transacción
        const category = await this.prisma.financeCategory.findUnique({
          where: { id: categoryId },
        });
        
        if (category) {
          categories[categoryId] = {
            id: categoryId,
            name: category.name,
            amount: 0,
            count: 0,
            color: category.color,
          };
        }
      }
      
      // Actualizar las estadísticas si la categoría existe
      if (categories[categoryId]) {
        categories[categoryId].amount += transaction.amount;
        categories[categoryId].count += 1;
      }
    }
    
    return Object.values(categories);
  }
} 