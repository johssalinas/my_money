import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/features/finances/bloc/finances_bloc.dart';
import 'package:my_money/features/finances/models/wallet_model.dart';
import 'package:my_money/shared/theme/app_theme.dart';

class WalletsScreen extends StatefulWidget {
  @override
  _WalletsScreenState createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _currency = 'USD';
  String _color = '#000000';
  bool _isDefault = false;
  List<String> _currencies = ['USD', 'EUR', 'GBP'];
  List<String> _colors = [
    '#000000',
    '#FF0000',
    '#00FF00',
    '#0000FF',
    '#FFFF00',
    '#FF00FF',
    '#00FFFF',
    '#FFFFFF',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la cuenta',
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
        icon: null, // Podríamos agregar selección de ícono
        isDefault: _isDefault,
      );

      context.read<FinancesBloc>().add(AddWalletEvent(wallet: wallet));
      Navigator.pop(context);
    }
  }
}
