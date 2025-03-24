import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/features/finances/bloc/finances_bloc.dart';
import 'package:my_money/features/finances/models/wallet_model.dart';
import 'package:my_money/shared/theme/app_theme.dart';

class AddWalletForm extends StatefulWidget {
  @override
  _AddWalletFormState createState() => _AddWalletFormState();
}

class _AddWalletFormState extends State<AddWalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _currency = 'MXN';
  String _color = '#1976D2';
  bool _isDefault = false;

  final List<String> _currencies = ['MXN', 'USD', 'EUR', 'GBP'];
  final List<String> _colors = [
    '#1976D2',
    '#388E3C',
    '#D32F2F',
    '#FFA000',
    '#7B1FA2',
    '#455A64',
    '#5D4037',
    '#00796B',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Crear nueva cuenta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la cuenta',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: InputDecoration(
                labelText: 'Saldo inicial',
                prefixIcon: Icon(Icons.monetization_on),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un saldo inicial';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un valor numérico válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(
                labelText: 'Moneda',
                border: OutlineInputBorder(),
              ),
              items:
                  _currencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _currency = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Color de la cuenta:'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _colors.map((color) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _color = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(color.replaceAll('#', '0xFF')),
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                _color == color
                                    ? Colors.white
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child:
                            _color == color
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Establecer como cuenta principal'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Crear cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final wallet = Wallet(
        id: '', // ID será generado por el backend
        name: _nameController.text,
        balance: double.parse(_balanceController.text),
        currency: _currency,
        color: _color,
        icon: null,
        isDefault: _isDefault,
      );

      context.read<FinancesBloc>().add(AddWalletEvent(wallet: wallet));
      Navigator.pop(context);
    }
  }
}
