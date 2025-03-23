import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { ShoppingService } from './shopping.service';
import { ShoppingItem, ShoppingCategory, ShoppingPeriodicity, Prisma } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('shopping')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('shopping')
export class ShoppingController {
  constructor(private readonly shoppingService: ShoppingService) {}

  // CATEGORÍAS DE COMPRAS
  @Post('categories')
  @ApiOperation({ summary: 'Crear una nueva categoría de compra' })
  @ApiResponse({ status: 201, description: 'Categoría creada correctamente' })
  async createCategory(@Body() data: Prisma.ShoppingCategoryCreateInput): Promise<ShoppingCategory> {
    return this.shoppingService.createCategory(data);
  }

  @Get('categories')
  @ApiOperation({ summary: 'Obtener todas las categorías de compra' })
  @ApiResponse({ status: 200, description: 'Listado de categorías' })
  async findAllCategories(): Promise<ShoppingCategory[]> {
    return this.shoppingService.findAllCategories();
  }

  @Get('categories/:id')
  @ApiOperation({ summary: 'Obtener una categoría de compra por ID' })
  @ApiResponse({ status: 200, description: 'Categoría encontrada' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async findCategoryById(@Param('id') id: string): Promise<ShoppingCategory> {
    return this.shoppingService.findCategoryById(id);
  }

  @Patch('categories/:id')
  @ApiOperation({ summary: 'Actualizar una categoría de compra' })
  @ApiResponse({ status: 200, description: 'Categoría actualizada correctamente' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async updateCategory(
    @Param('id') id: string,
    @Body() data: Prisma.ShoppingCategoryUpdateInput,
  ): Promise<ShoppingCategory> {
    return this.shoppingService.updateCategory(id, data);
  }

  @Delete('categories/:id')
  @ApiOperation({ summary: 'Eliminar una categoría de compra' })
  @ApiResponse({ status: 200, description: 'Categoría eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async deleteCategory(@Param('id') id: string): Promise<ShoppingCategory> {
    return this.shoppingService.deleteCategory(id);
  }

  // ITEMS DE COMPRAS
  @Post('items')
  @ApiOperation({ summary: 'Crear un nuevo item de compra' })
  @ApiResponse({ status: 201, description: 'Item creado correctamente' })
  async createItem(@Body() data: Prisma.ShoppingItemCreateInput, @Request() req): Promise<ShoppingItem> {
    // Asignar el usuario actual como creador
    data.addedBy = { connect: { id: req.user.id } };
    return this.shoppingService.createItem(data);
  }

  @Get('items')
  @ApiOperation({ summary: 'Obtener items de compra con filtros opcionales' })
  @ApiResponse({ status: 200, description: 'Listado de items' })
  async findAllItems(
    @Query('categoryId') categoryId?: string,
    @Query('purchased') purchased?: boolean,
    @Query('periodicity') periodicity?: ShoppingPeriodicity,
  ): Promise<ShoppingItem[]> {
    return this.shoppingService.findAllItems({
      categoryId,
      purchased: purchased === undefined ? undefined : purchased === true,
      periodicity: periodicity as string,
    });
  }

  @Get('items/:id')
  @ApiOperation({ summary: 'Obtener un item de compra por ID' })
  @ApiResponse({ status: 200, description: 'Item encontrado' })
  @ApiResponse({ status: 404, description: 'Item no encontrado' })
  async findItemById(@Param('id') id: string): Promise<ShoppingItem> {
    return this.shoppingService.findItemById(id);
  }

  @Patch('items/:id')
  @ApiOperation({ summary: 'Actualizar un item de compra' })
  @ApiResponse({ status: 200, description: 'Item actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Item no encontrado' })
  async updateItem(
    @Param('id') id: string,
    @Body() data: Prisma.ShoppingItemUpdateInput,
  ): Promise<ShoppingItem> {
    return this.shoppingService.updateItem(id, data);
  }

  @Patch('items/:id/toggle-purchased')
  @ApiOperation({ summary: 'Marcar/desmarcar un item como comprado' })
  @ApiResponse({ status: 200, description: 'Estado de compra actualizado' })
  @ApiResponse({ status: 404, description: 'Item no encontrado' })
  async toggleItemPurchased(@Param('id') id: string): Promise<ShoppingItem> {
    return this.shoppingService.toggleItemPurchased(id);
  }

  @Delete('items/:id')
  @ApiOperation({ summary: 'Eliminar un item de compra' })
  @ApiResponse({ status: 200, description: 'Item eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Item no encontrado' })
  async deleteItem(@Param('id') id: string): Promise<ShoppingItem> {
    return this.shoppingService.deleteItem(id);
  }

  // ESTADÍSTICAS Y RESÚMENES
  @Get('summary')
  @ApiOperation({ summary: 'Obtener resumen de la lista de compras' })
  @ApiResponse({ status: 200, description: 'Resumen de compras' })
  async getShoppingListSummary() {
    return this.shoppingService.getShoppingListSummary();
  }
} 