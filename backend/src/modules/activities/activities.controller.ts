import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { ActivitiesService } from './activities.service';
import { Activity, Prisma, ActivityStatus } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('activities')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('activities')
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  @ApiOperation({ summary: 'Crear una nueva actividad' })
  @ApiResponse({ status: 201, description: 'Actividad creada correctamente' })
  async create(@Body() data: Prisma.ActivityCreateInput, @Request() req): Promise<Activity> {
    // Asignar el usuario actual como creador
    data.createdBy = { connect: { id: req.user.id } };
    return this.activitiesService.create(data);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todas las actividades' })
  @ApiResponse({ status: 200, description: 'Listado de actividades' })
  async findAll(@Query('status') status?: string, @Query('assignedTo') assignedTo?: string): Promise<Activity[]> {
    if (status) {
      return this.activitiesService.getByStatus(status);
    }
    
    if (assignedTo) {
      return this.activitiesService.getByAssignedUser(assignedTo);
    }
    
    return this.activitiesService.findAll({});
  }

  @Get('kanban')
  @ApiOperation({ summary: 'Obtener actividades organizadas para Kanban' })
  @ApiResponse({ status: 200, description: 'Actividades organizadas por estado' })
  async getKanbanBoard(): Promise<{ todo: Activity[]; inProgress: Activity[]; done: Activity[] }> {
    const todo = await this.activitiesService.getByStatus(ActivityStatus.TODO);
    const inProgress = await this.activitiesService.getByStatus(ActivityStatus.IN_PROGRESS);
    const done = await this.activitiesService.getByStatus(ActivityStatus.DONE);
    
    return { todo, inProgress, done };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una actividad por ID' })
  @ApiResponse({ status: 200, description: 'Actividad encontrada' })
  @ApiResponse({ status: 404, description: 'Actividad no encontrada' })
  async findOne(@Param('id') id: string): Promise<Activity> {
    return this.activitiesService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar una actividad' })
  @ApiResponse({ status: 200, description: 'Actividad actualizada correctamente' })
  @ApiResponse({ status: 404, description: 'Actividad no encontrada' })
  async update(
    @Param('id') id: string,
    @Body() data: Prisma.ActivityUpdateInput,
  ): Promise<Activity> {
    return this.activitiesService.update(id, data);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Actualizar el estado de una actividad' })
  @ApiResponse({ status: 200, description: 'Estado actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Actividad no encontrada' })
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: ActivityStatus,
  ): Promise<Activity> {
    return this.activitiesService.update(id, { status });
  }

  @Patch(':id/assign')
  @ApiOperation({ summary: 'Asignar una actividad a un usuario' })
  @ApiResponse({ status: 200, description: 'Actividad asignada correctamente' })
  @ApiResponse({ status: 404, description: 'Actividad no encontrada' })
  async assignActivity(
    @Param('id') id: string,
    @Body('userId') userId: string,
  ): Promise<Activity> {
    return this.activitiesService.update(id, {
      assignedTo: userId ? { connect: { id: userId } } : { disconnect: true },
    });
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar una actividad' })
  @ApiResponse({ status: 200, description: 'Actividad eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Actividad no encontrada' })
  async remove(@Param('id') id: string): Promise<Activity> {
    return this.activitiesService.remove(id);
  }
} 