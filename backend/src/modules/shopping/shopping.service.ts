import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ShoppingItem, ShoppingCategory, Prisma } from '@prisma/client';

@Injectable()
export class ShoppingService {
  constructor(private prisma: PrismaService) {}

  // CATEGORÍAS DE COMPRAS
  async createCategory(data: Prisma.ShoppingCategoryCreateInput): Promise<ShoppingCategory> {
    return this.prisma.shoppingCategory.create({
      data,
    });
  }

  async findAllCategories(): Promise<ShoppingCategory[]> {
    return this.prisma.shoppingCategory.findMany({
      include: {
        _count: {
          select: {
            items: true,
          },
        },
      },
    });
  }

  async findCategoryById(id: string): Promise<ShoppingCategory> {
    const category = await this.prisma.shoppingCategory.findUnique({
      where: { id },
      include: {
        items: true,
      },
    });

    if (!category) {
      throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
    }

    return category;
  }

  async updateCategory(id: string, data: Prisma.ShoppingCategoryUpdateInput): Promise<ShoppingCategory> {
    try {
      return await this.prisma.shoppingCategory.update({
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

  async deleteCategory(id: string): Promise<ShoppingCategory> {
    try {
      return await this.prisma.shoppingCategory.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
      }
      throw error;
    }
  }

  // ITEMS DE COMPRAS
  async createItem(data: Prisma.ShoppingItemCreateInput): Promise<ShoppingItem> {
    return this.prisma.shoppingItem.create({
      data,
      include: {
        category: true,
        addedBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findAllItems(params?: {
    categoryId?: string;
    purchased?: boolean;
    periodicity?: string;
  }): Promise<ShoppingItem[]> {
    const { categoryId, purchased, periodicity } = params || {};
    
    const where: Prisma.ShoppingItemWhereInput = {};
    
    if (categoryId) {
      where.categoryId = categoryId;
    }
    
    if (purchased !== undefined) {
      where.purchased = purchased;
    }
    
    if (periodicity) {
      where.periodicity = periodicity as any;
    }
    
    return this.prisma.shoppingItem.findMany({
      where,
      include: {
        category: true,
        addedBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findItemById(id: string): Promise<ShoppingItem> {
    const item = await this.prisma.shoppingItem.findUnique({
      where: { id },
      include: {
        category: true,
        addedBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException(`Item con ID ${id} no encontrado`);
    }

    return item;
  }

  async updateItem(id: string, data: Prisma.ShoppingItemUpdateInput): Promise<ShoppingItem> {
    try {
      return await this.prisma.shoppingItem.update({
        where: { id },
        data,
        include: {
          category: true,
          addedBy: {
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
        throw new NotFoundException(`Item con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async toggleItemPurchased(id: string): Promise<ShoppingItem> {
    const item = await this.findItemById(id);
    return this.updateItem(id, { purchased: !item.purchased });
  }

  async deleteItem(id: string): Promise<ShoppingItem> {
    try {
      return await this.prisma.shoppingItem.delete({
        where: { id },
        include: {
          category: true,
          addedBy: {
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
        throw new NotFoundException(`Item con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  // ESTADÍSTICAS Y RESÚMENES
  async getShoppingListSummary(): Promise<any> {
    const [totalItems, purchasedItems, weeklyItems, monthlyItems, totalCategories] = await Promise.all([
      this.prisma.shoppingItem.count(),
      this.prisma.shoppingItem.count({ where: { purchased: true } }),
      this.prisma.shoppingItem.count({ where: { periodicity: 'WEEKLY' } }),
      this.prisma.shoppingItem.count({ where: { periodicity: 'MONTHLY' } }),
      this.prisma.shoppingCategory.count(),
    ]);
    
    // Calcular el total estimado
    const items = await this.prisma.shoppingItem.findMany({
      where: { purchased: false },
      select: { price: true, quantity: true },
    });
    
    let totalEstimatedCost = 0;
    items.forEach(item => {
      if (item.price) {
        totalEstimatedCost += item.price * item.quantity;
      }
    });
    
    return {
      totalItems,
      purchasedItems,
      pendingItems: totalItems - purchasedItems,
      weeklyItems,
      monthlyItems,
      totalCategories,
      totalEstimatedCost,
    };
  }
} 