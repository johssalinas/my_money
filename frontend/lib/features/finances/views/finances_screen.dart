import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/features/finances/bloc/finances_bloc.dart';
import 'package:my_money/features/finances/models/wallet_model.dart';
import 'package:my_money/features/finances/services/finances_service.dart';
import 'package:my_money/features/finances/views/wallets_screen.dart';
import 'package:my_money/features/finances/views/transactions_screen.dart';
import 'package:my_money/features/finances/views/budgets_screen.dart';
import 'package:my_money/features/finances/views/loans_screen.dart';
import 'package:my_money/features/finances/views/add_wallet_form.dart';
import 'package:my_money/features/finances/views/add_transaction_form.dart';
import 'package:my_money/features/finances/views/add_budget_form.dart';
import 'package:my_money/features/finances/views/add_loan_form.dart';
import 'package:my_money/shared/theme/app_theme.dart';
import 'package:my_money/shared/widgets/custom_button.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({Key? key}) : super(key: key);

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar las billeteras al iniciar
    context.read<FinancesBloc>().add(LoadWalletsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Resumen financiero
          _buildFinancialSummary(),

          // Tabs de navegación
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Cuentas', icon: Icon(Icons.account_balance_wallet)),
              Tab(text: 'Movimientos', icon: Icon(Icons.sync_alt)),
              Tab(text: 'Presupuesto', icon: Icon(Icons.pie_chart)),
              Tab(text: 'Préstamos', icon: Icon(Icons.money)),
            ],
          ),

          // Contenido de los tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WalletsScreen(),
                TransactionsScreen(),
                BudgetsScreen(),
                LoansScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFinancialSummary() {
    return BlocBuilder<FinancesBloc, FinancesState>(
      builder: (context, state) {
        if (state is WalletsLoadedState) {
          final totalBalance = state.wallets.fold(
            0.0,
            (sum, wallet) => sum + wallet.balance,
          );

          return Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Total',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '\$${totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.wallets.length} cuentas activas',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    TextButton(
                      onPressed: () {
                        _tabController.animateTo(
                          0,
                        ); // Ir a la pestaña de cuentas
                      },
                      child: Text(
                        'Ver todas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: AppTheme.primaryColor,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Mostrar diferentes modales según la pestaña activa
        switch (_tabController.index) {
          case 0:
            _showAddWalletModal();
            break;
          case 1:
            _showAddTransactionModal();
            break;
          case 2:
            _showAddBudgetModal();
            break;
          case 3:
            _showAddLoanModal();
            break;
        }
      },
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add),
    );
  }

  void _showAddWalletModal() {
    // Implementar modal para añadir billetera
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddWalletForm(),
    );
  }

  void _showAddTransactionModal() {
    // Implementar modal para añadir transacción
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTransactionForm(),
    );
  }

  void _showAddBudgetModal() {
    // Implementar modal para añadir presupuesto
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddBudgetForm(),
    );
  }

  void _showAddLoanModal() {
    // Implementar modal para añadir préstamo
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLoanForm(),
    );
  }
}
