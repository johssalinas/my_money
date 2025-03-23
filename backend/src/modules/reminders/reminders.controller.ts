import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { RemindersService } from './reminders.service';
import { Reminder, Prisma, ReminderPriority } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('reminders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reminders')
export class RemindersController {
  constructor(private readonly remindersService: RemindersService) {}

  @Post()
  @ApiOperation({ summary: 'Crear un nuevo recordatorio' })
  @ApiResponse({ status: 201, description: 'Recordatorio creado correctamente' })
  async create(@Body() data: Prisma.ReminderCreateInput, @Request() req): Promise<Reminder> {
    // Asignar el usuario actual como propietario del recordatorio
    data.user = { connect: { id: req.user.id } };
    return this.remindersService.create(data);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todos los recordatorios del usuario' })
  @ApiResponse({ status: 200, description: 'Listado de recordatorios' })
  async findAll(
    @Request() req,
    @Query('priority') priority?: ReminderPriority,
    @Query('upcoming') upcoming?: boolean,
  ): Promise<Reminder[]> {
    const userId = req.user.id;
    
    if (priority) {
      return this.remindersService.findByPriority(priority);
    }
    
    if (upcoming) {
      return this.remindersService.findUpcoming(userId);
    }
    
    return this.remindersService.findByUser(userId);
  }

  @Get('high-priority')
  @ApiOperation({ summary: 'Obtener recordatorios de alta prioridad' })
  @ApiResponse({ status: 200, description: 'Recordatorios de alta prioridad' })
  async getHighPriority(@Request() req): Promise<Reminder[]> {
    return this.remindersService.findByPriority(ReminderPriority.HIGH);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un recordatorio por ID' })
  @ApiResponse({ status: 200, description: 'Recordatorio encontrado' })
  @ApiResponse({ status: 404, description: 'Recordatorio no encontrado' })
  async findOne(@Param('id') id: string): Promise<Reminder> {
    return this.remindersService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un recordatorio' })
  @ApiResponse({ status: 200, description: 'Recordatorio actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Recordatorio no encontrado' })
  async update(
    @Param('id') id: string,
    @Body() data: Prisma.ReminderUpdateInput,
  ): Promise<Reminder> {
    return this.remindersService.update(id, data);
  }

  @Patch(':id/complete')
  @ApiOperation({ summary: 'Marcar un recordatorio como completado' })
  @ApiResponse({ status: 200, description: 'Recordatorio marcado como completado' })
  @ApiResponse({ status: 404, description: 'Recordatorio no encontrado' })
  async markAsCompleted(@Param('id') id: string): Promise<Reminder> {
    return this.remindersService.markAsCompleted(id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar un recordatorio' })
  @ApiResponse({ status: 200, description: 'Recordatorio eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Recordatorio no encontrado' })
  async remove(@Param('id') id: string): Promise<Reminder> {
    return this.remindersService.remove(id);
  }
} 