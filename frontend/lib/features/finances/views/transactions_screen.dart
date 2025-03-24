import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_money/features/finances/bloc/finances_bloc.dart';
import 'package:my_money/features/finances/models/transaction_model.dart';
import 'package:my_money/features/finances/views/add_transaction_form.dart';
import 'package:my_money/shared/theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedWalletId;
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    // Cargar todas las transacciones al iniciar
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<FinancesBloc>().add(
      LoadTransactionsEvent(
        walletId: _selectedWalletId,
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtros
        _buildFilters(),

        // Lista de transacciones
        Expanded(
          child: BlocBuilder<FinancesBloc, FinancesState>(
            builder: (context, state) {
              if (state is FinancesLoadingState) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is TransactionsLoadedState) {
                if (state.transactions.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildTransactionsList(state.transactions);
              }

              // Estado inicial o de error
              return Center(
                child: ElevatedButton(
                  onPressed: _loadTransactions,
                  child: Text('Cargar transacciones'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<FinancesBloc, FinancesState>(
                  builder: (context, state) {
                    if (state is WalletsLoadedState) {
                      return DropdownButtonFormField<String?>(
                        decoration: InputDecoration(
                          labelText: 'Cuenta',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _selectedWalletId,
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todas las cuentas'),
                          ),
                          ...state.wallets.map((wallet) {
                            return DropdownMenuItem<String?>(
                              value: wallet.id,
                              child: Text(wallet.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedWalletId = value;
                          });
                          _loadTransactions();
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () => _showFilterModal(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sync_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay transacciones',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Mostrar formulario para añadir transacción
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddTransactionForm(),
              );
            },
            child: Text('Registrar movimiento'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    // Agrupar transacciones por fecha
    final grouped = <String, List<Transaction>>{};
    for (var transaction in transactions) {
      final dateStr = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(transaction);
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateStr = grouped.keys.elementAt(index);
        final date = DateTime.parse(dateStr);
        final transactionsForDate = grouped[dateStr]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormat('EEEE, d MMMM yyyy', 'es').format(date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ...transactionsForDate.map((transaction) {
              return TransactionListItem(transaction: transaction);
            }).toList(),
            Divider(height: 1),
          ],
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar transacciones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Tipo de transacción:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('Todos'),
                        selected: _selectedType == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = null;
                          });
                        },
                      ),
                      ...TransactionType.values.map((type) {
                        return FilterChip(
                          label: Text(_getTransactionTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.date_range),
                          label: Text(
                            'Desde: ${_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'No seleccionado'}',
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.date_range),
                          label: Text(
                            'Hasta: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'No seleccionado'}',
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(Duration(days: 1)),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedWalletId = null;
                            _startDate = null;
                            _endDate = null;
                            _selectedType = null;
                          });
                        },
                        child: Text('Limpiar filtros'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadTransactions();
                        },
                        child: Text('Aplicar filtros'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Ingresos';
      case TransactionType.expense:
        return 'Gastos';
      case TransactionType.transfer:
        return 'Transferencias';
      case TransactionType.loan:
        return 'Préstamos';
    }
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData iconData;
    String typeText;

    switch (transaction.type) {
      case TransactionType.income:
        iconColor = AppTheme.successColor;
        iconData = Icons.arrow_downward;
        typeText = 'Ingreso';
        break;
      case TransactionType.expense:
        iconColor = AppTheme.errorColor;
        iconData = Icons.arrow_upward;
        typeText = 'Gasto';
        break;
      case TransactionType.transfer:
        iconColor = AppTheme.infoColor;
        iconData = Icons.swap_horiz;
        typeText = 'Transferencia';
        break;
      case TransactionType.loan:
        iconColor = AppTheme.warningColor;
        iconData = Icons.money;
        typeText = 'Préstamo';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        transaction.description ?? typeText,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${transaction.categoryName} • ${transaction.walletName}',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.type == TransactionType.expense ? '-' : ''}${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  transaction.type == TransactionType.expense
                      ? AppTheme.errorColor
                      : transaction.type == TransactionType.income
                      ? AppTheme.successColor
                      : null,
            ),
          ),
          Text(
            DateFormat('HH:mm').format(transaction.date),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        // Mostrar detalles de la transacción
      },
    );
  }
}
