import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { MealPlan, Prisma, MealType } from '@prisma/client';

@Injectable()
export class MealPlanningService {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.MealPlanCreateInput): Promise<MealPlan> {
    return this.prisma.mealPlan.create({
      data,
      include: {
        createdBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findAll(params?: {
    userId?: string;
    dateFrom?: Date;
    dateTo?: Date;
    mealType?: MealType;
  }): Promise<MealPlan[]> {
    const { userId, dateFrom, dateTo, mealType } = params || {};
    
    const where: Prisma.MealPlanWhereInput = {};
    
    if (userId) {
      where.createdById = userId;
    }
    
    if (dateFrom || dateTo) {
      where.date = {};
      if (dateFrom) where.date.gte = dateFrom;
      if (dateTo) where.date.lte = dateTo;
    }
    
    if (mealType) {
      where.mealType = mealType;
    }
    
    return this.prisma.mealPlan.findMany({
      where,
      include: {
        createdBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        date: 'asc',
      },
    });
  }

  async findOne(id: string): Promise<MealPlan> {
    const mealPlan = await this.prisma.mealPlan.findUnique({
      where: { id },
      include: {
        createdBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!mealPlan) {
      throw new NotFoundException(`Plan de comida con ID ${id} no encontrado`);
    }

    return mealPlan;
  }

  async update(id: string, data: Prisma.MealPlanUpdateInput): Promise<MealPlan> {
    try {
      return await this.prisma.mealPlan.update({
        where: { id },
        data,
        include: {
          createdBy: {
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
        throw new NotFoundException(`Plan de comida con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async remove(id: string): Promise<MealPlan> {
    try {
      return await this.prisma.mealPlan.delete({
        where: { id },
        include: {
          createdBy: {
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
        throw new NotFoundException(`Plan de comida con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async getWeeklyPlan(userId: string, date: Date): Promise<any> {
    // Obtener el primer día de la semana (Lunes)
    const day = date.getDay(); // 0 = Domingo, 1 = Lunes, ...
    const diff = date.getDate() - day + (day === 0 ? -6 : 1); // Ajustar si es domingo
    const monday = new Date(date);
    monday.setDate(diff);
    monday.setHours(0, 0, 0, 0);
    
    // Obtener el último día de la semana (Domingo)
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    sunday.setHours(23, 59, 59, 999);
    
    // Obtener todas las comidas de la semana
    const meals = await this.findAll({
      userId,
      dateFrom: monday,
      dateTo: sunday,
    });
    
    // Organizar por día y tipo de comida
    const weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const result = {};
    
    weekDays.forEach((dayName, index) => {
      const currentDate = new Date(monday);
      currentDate.setDate(monday.getDate() + index);
      
      result[dayName] = {
        date: new Date(currentDate),
        meals: {
          BREAKFAST: null,
          MIDMORNING: null,
          LUNCH: null,
          DINNER: null,
        },
      };
    });
    
    // Rellenar con las comidas planificadas
    meals.forEach(meal => {
      const mealDate = new Date(meal.date);
      const dayOfWeek = mealDate.getDay();
      const adjustedDay = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Convertir de 0-6 (Dom-Sáb) a 0-6 (Lun-Dom)
      const dayName = weekDays[adjustedDay];
      
      result[dayName].meals[meal.mealType] = meal;
    });
    
    return {
      weekStart: monday,
      weekEnd: sunday,
      days: result,
    };
  }

  async getEstimatedWeekCost(userId: string, date: Date): Promise<any> {
    const weekPlan = await this.getWeeklyPlan(userId, date);
    
    let totalCost = 0;
    let totalTime = 0;
    let mealCount = 0;
    
    Object.values(weekPlan.days).forEach((day: any) => {
      Object.values(day.meals).forEach((meal: MealPlan) => {
        if (meal) {
          totalCost += meal.estimatedCost || 0;
          totalTime += meal.preparationTime || 0;
          mealCount++;
        }
      });
    });
    
    return {
      totalCost,
      totalTime,
      mealCount,
      averageCostPerMeal: mealCount > 0 ? totalCost / mealCount : 0,
      averageTimePerMeal: mealCount > 0 ? totalTime / mealCount : 0,
      weekStart: weekPlan.weekStart,
      weekEnd: weekPlan.weekEnd,
    };
  }
} 