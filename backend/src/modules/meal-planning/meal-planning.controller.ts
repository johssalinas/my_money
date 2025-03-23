import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { MealPlanningService } from './meal-planning.service';
import { MealPlan, MealType, Prisma } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('meal-planning')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('meal-planning')
export class MealPlanningController {
  constructor(private readonly mealPlanningService: MealPlanningService) {}

  @Post()
  @ApiOperation({ summary: 'Crear un nuevo plan de comida' })
  @ApiResponse({ status: 201, description: 'Plan de comida creado correctamente' })
  async create(@Body() data: Prisma.MealPlanCreateInput, @Request() req): Promise<MealPlan> {
    // Asignar el usuario actual como creador
    data.createdBy = { connect: { id: req.user.id } };
    return this.mealPlanningService.create(data);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener planes de comida con filtros opcionales' })
  @ApiResponse({ status: 200, description: 'Listado de planes de comida' })
  async findAll(
    @Request() req,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
    @Query('mealType') mealType?: MealType,
  ): Promise<MealPlan[]> {
    return this.mealPlanningService.findAll({
      userId: req.user.id,
      dateFrom: dateFrom ? new Date(dateFrom) : undefined,
      dateTo: dateTo ? new Date(dateTo) : undefined,
      mealType: mealType as MealType,
    });
  }

  @Get('weekly')
  @ApiOperation({ summary: 'Obtener plan semanal de comidas' })
  @ApiResponse({ status: 200, description: 'Plan semanal' })
  async getWeeklyPlan(
    @Request() req,
    @Query('date') date?: string,
  ): Promise<any> {
    const planDate = date ? new Date(date) : new Date();
    return this.mealPlanningService.getWeeklyPlan(req.user.id, planDate);
  }

  @Get('estimated-cost')
  @ApiOperation({ summary: 'Obtener costo estimado de la semana' })
  @ApiResponse({ status: 200, description: 'Costo estimado' })
  async getEstimatedWeekCost(
    @Request() req,
    @Query('date') date?: string,
  ): Promise<any> {
    const planDate = date ? new Date(date) : new Date();
    return this.mealPlanningService.getEstimatedWeekCost(req.user.id, planDate);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un plan de comida por ID' })
  @ApiResponse({ status: 200, description: 'Plan de comida encontrado' })
  @ApiResponse({ status: 404, description: 'Plan de comida no encontrado' })
  async findOne(@Param('id') id: string): Promise<MealPlan> {
    return this.mealPlanningService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un plan de comida' })
  @ApiResponse({ status: 200, description: 'Plan de comida actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Plan de comida no encontrado' })
  async update(
    @Param('id') id: string,
    @Body() data: Prisma.MealPlanUpdateInput,
  ): Promise<MealPlan> {
    return this.mealPlanningService.update(id, data);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar un plan de comida' })
  @ApiResponse({ status: 200, description: 'Plan de comida eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Plan de comida no encontrado' })
  async remove(@Param('id') id: string): Promise<MealPlan> {
    return this.mealPlanningService.remove(id);
  }
} 