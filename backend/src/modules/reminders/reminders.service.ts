import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Reminder, Prisma, ReminderPriority } from '@prisma/client';

@Injectable()
export class RemindersService {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.ReminderCreateInput): Promise<Reminder> {
    return this.prisma.reminder.create({
      data,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findAll(params: {
    skip?: number;
    take?: number;
    where?: Prisma.ReminderWhereInput;
    orderBy?: Prisma.ReminderOrderByWithRelationInput;
  }): Promise<Reminder[]> {
    const { skip, take, where, orderBy } = params;
    return this.prisma.reminder.findMany({
      skip,
      take,
      where,
      orderBy,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findOne(id: string): Promise<Reminder> {
    const reminder = await this.prisma.reminder.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!reminder) {
      throw new NotFoundException(`Recordatorio con ID ${id} no encontrado`);
    }

    return reminder;
  }

  async update(id: string, data: Prisma.ReminderUpdateInput): Promise<Reminder> {
    try {
      return await this.prisma.reminder.update({
        where: { id },
        data,
        include: {
          user: {
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
        throw new NotFoundException(`Recordatorio con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async remove(id: string): Promise<Reminder> {
    try {
      return await this.prisma.reminder.delete({
        where: { id },
        include: {
          user: {
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
        throw new NotFoundException(`Recordatorio con ID ${id} no encontrado`);
      }
      throw error;
    }
  }

  async findByUser(userId: string): Promise<Reminder[]> {
    return this.prisma.reminder.findMany({
      where: {
        userId,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        dateTime: 'asc',
      },
    });
  }

  async findByPriority(priority: ReminderPriority): Promise<Reminder[]> {
    return this.prisma.reminder.findMany({
      where: {
        priority,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        dateTime: 'asc',
      },
    });
  }

  async findUpcoming(userId: string): Promise<Reminder[]> {
    const now = new Date();
    
    return this.prisma.reminder.findMany({
      where: {
        userId,
        dateTime: {
          gte: now,
        },
        completed: false,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        dateTime: 'asc',
      },
    });
  }

  async markAsCompleted(id: string): Promise<Reminder> {
    return this.update(id, { completed: true });
  }
} 