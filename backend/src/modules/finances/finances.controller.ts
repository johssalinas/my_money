import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { FinancesService } from './finances.service';
import { Transaction, Wallet, FinanceCategory, Loan, TransactionType, LoanType } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('finances')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('finances')
export class FinancesController {
  constructor(private readonly financesService: FinancesService) {}

  // CARTERAS (WALLETS)
  @Post('wallets')
  @ApiOperation({ summary: 'Crear una nueva cartera' })
  @ApiResponse({ status: 201, description: 'Cartera creada correctamente' })
  async createWallet(@Body() data: any, @Request() req) {
    // Asignar el usuario actual como propietario
    data.owner = { connect: { id: req.user.id } };
    return this.financesService.createWallet(data);
  }

  @Get('wallets')
  @ApiOperation({ summary: 'Obtener todas las carteras del usuario' })
  @ApiResponse({ status: 200, description: 'Listado de carteras' })
  async findWallets(@Request() req) {
    return this.financesService.findWallets(req.user.id);
  }

  @Get('wallets/:id')
  @ApiOperation({ summary: 'Obtener una cartera por ID' })
  @ApiResponse({ status: 200, description: 'Cartera encontrada' })
  @ApiResponse({ status: 404, description: 'Cartera no encontrada' })
  async findWalletById(@Param('id') id: string) {
    return this.financesService.findWalletById(id);
  }

  @Patch('wallets/:id')
  @ApiOperation({ summary: 'Actualizar una cartera' })
  @ApiResponse({ status: 200, description: 'Cartera actualizada correctamente' })
  @ApiResponse({ status: 404, description: 'Cartera no encontrada' })
  async updateWallet(@Param('id') id: string, @Body() data: any) {
    return this.financesService.updateWallet(id, data);
  }

  @Delete('wallets/:id')
  @ApiOperation({ summary: 'Eliminar una cartera' })
  @ApiResponse({ status: 200, description: 'Cartera eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Cartera no encontrada' })
  async deleteWallet(@Param('id') id: string) {
    return this.financesService.deleteWallet(id);
  }

  // TRANSACCIONES
  @Post('transactions')
  @ApiOperation({ summary: 'Crear una nueva transacción' })
  @ApiResponse({ status: 201, description: 'Transacción creada correctamente' })
  async createTransaction(@Body() data: any, @Request() req) {
    // Asignar el usuario actual como creador
    data.user = { connect: { id: req.user.id } };
    return this.financesService.createTransaction(data);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Obtener transacciones con filtros opcionales' })
  @ApiResponse({ status: 200, description: 'Listado de transacciones' })
  async findTransactions(
    @Request() req,
    @Query('walletId') walletId?: string,
    @Query('categoryId') categoryId?: string,
    @Query('type') type?: TransactionType,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
  ) {
    return this.financesService.findTransactions({
      userId: req.user.id,
      walletId,
      categoryId,
      type: type as any,
      dateFrom: dateFrom ? new Date(dateFrom) : undefined,
      dateTo: dateTo ? new Date(dateTo) : undefined,
    });
  }

  @Get('transactions/:id')
  @ApiOperation({ summary: 'Obtener una transacción por ID' })
  @ApiResponse({ status: 200, description: 'Transacción encontrada' })
  @ApiResponse({ status: 404, description: 'Transacción no encontrada' })
  async findTransactionById(@Param('id') id: string) {
    return this.financesService.findTransactionById(id);
  }

  @Delete('transactions/:id')
  @ApiOperation({ summary: 'Eliminar una transacción' })
  @ApiResponse({ status: 200, description: 'Transacción eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Transacción no encontrada' })
  async deleteTransaction(@Param('id') id: string) {
    return this.financesService.deleteTransaction(id);
  }

  // CATEGORÍAS FINANCIERAS
  @Post('categories')
  @ApiOperation({ summary: 'Crear una nueva categoría financiera' })
  @ApiResponse({ status: 201, description: 'Categoría creada correctamente' })
  async createCategory(@Body() data: any) {
    return this.financesService.createCategory(data);
  }

  @Get('categories')
  @ApiOperation({ summary: 'Obtener categorías financieras con filtro opcional por tipo' })
  @ApiResponse({ status: 200, description: 'Listado de categorías' })
  async findCategories(@Query('type') type?: TransactionType) {
    return this.financesService.findCategories(type as any);
  }

  @Get('categories/:id')
  @ApiOperation({ summary: 'Obtener una categoría financiera por ID' })
  @ApiResponse({ status: 200, description: 'Categoría encontrada' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async findCategoryById(@Param('id') id: string) {
    return this.financesService.findCategoryById(id);
  }

  @Patch('categories/:id')
  @ApiOperation({ summary: 'Actualizar una categoría financiera' })
  @ApiResponse({ status: 200, description: 'Categoría actualizada correctamente' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async updateCategory(@Param('id') id: string, @Body() data: any) {
    return this.financesService.updateCategory(id, data);
  }

  @Delete('categories/:id')
  @ApiOperation({ summary: 'Eliminar una categoría financiera' })
  @ApiResponse({ status: 200, description: 'Categoría eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  async deleteCategory(@Param('id') id: string) {
    return this.financesService.deleteCategory(id);
  }

  // PRÉSTAMOS
  @Post('loans')
  @ApiOperation({ summary: 'Crear un nuevo préstamo' })
  @ApiResponse({ status: 201, description: 'Préstamo creado correctamente' })
  async createLoan(@Body() data: any) {
    return this.financesService.createLoan(data);
  }

  @Get('loans')
  @ApiOperation({ summary: 'Obtener préstamos con filtros opcionales' })
  @ApiResponse({ status: 200, description: 'Listado de préstamos' })
  async findLoans(
    @Query('type') type?: LoanType,
    @Query('isPaid') isPaid?: boolean,
  ) {
    return this.financesService.findLoans(
      type as any,
      isPaid === undefined ? undefined : isPaid === true,
    );
  }

  @Get('loans/:id')
  @ApiOperation({ summary: 'Obtener un préstamo por ID' })
  @ApiResponse({ status: 200, description: 'Préstamo encontrado' })
  @ApiResponse({ status: 404, description: 'Préstamo no encontrado' })
  async findLoanById(@Param('id') id: string) {
    return this.financesService.findLoanById(id);
  }

  @Patch('loans/:id')
  @ApiOperation({ summary: 'Actualizar un préstamo' })
  @ApiResponse({ status: 200, description: 'Préstamo actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Préstamo no encontrado' })
  async updateLoan(@Param('id') id: string, @Body() data: any) {
    return this.financesService.updateLoan(id, data);
  }

  @Patch('loans/:id/paid')
  @ApiOperation({ summary: 'Marcar un préstamo como pagado' })
  @ApiResponse({ status: 200, description: 'Préstamo marcado como pagado' })
  @ApiResponse({ status: 404, description: 'Préstamo no encontrado' })
  async markLoanAsPaid(@Param('id') id: string) {
    return this.financesService.markLoanAsPaid(id);
  }

  @Delete('loans/:id')
  @ApiOperation({ summary: 'Eliminar un préstamo' })
  @ApiResponse({ status: 200, description: 'Préstamo eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Préstamo no encontrado' })
  async deleteLoan(@Param('id') id: string) {
    return this.financesService.deleteLoan(id);
  }

  // ESTADÍSTICAS Y REPORTES
  @Get('reports/monthly-balance')
  @ApiOperation({ summary: 'Obtener balance mensual' })
  @ApiResponse({ status: 200, description: 'Balance mensual' })
  async getMonthlyBalance(
    @Request() req,
    @Query('year') year: number,
    @Query('month') month: number,
  ) {
    return this.financesService.getMonthlyBalance(req.user.id, year, month);
  }

  @Get('reports/category-distribution')
  @ApiOperation({ summary: 'Obtener distribución por categorías' })
  @ApiResponse({ status: 200, description: 'Distribución por categorías' })
  async getCategoryDistribution(
    @Request() req,
    @Query('type') type: TransactionType,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
  ) {
    return this.financesService.getCategoryDistribution(
      req.user.id,
      type as any,
      dateFrom ? new Date(dateFrom) : undefined,
      dateTo ? new Date(dateTo) : undefined,
    );
  }
} 