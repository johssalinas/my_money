import 'package:my_money/core/api/api_service.dart';
import 'package:my_money/features/finances/models/wallet_model.dart';
import 'package:my_money/features/finances/models/transaction_model.dart';
import 'package:my_money/features/finances/models/category_model.dart';
import 'package:my_money/features/finances/models/budget_model.dart';
import 'package:my_money/features/finances/models/loan_model.dart';

class FinancesService {
  final ApiService _apiService;

  FinancesService(this._apiService);

  // Wallets
  Future<List<Wallet>> getWallets() async {
    final response = await _apiService.get('/wallets');
    return (response as List).map((json) => Wallet.fromJson(json)).toList();
  }

  Future<Wallet> createWallet(Wallet wallet) async {
    final response = await _apiService.post('/wallets', data: wallet.toJson());
    return Wallet.fromJson(response);
  }

  Future<Wallet> updateWallet(String id, Wallet wallet) async {
    final response = await _apiService.patch('/wallets/$id', data: wallet.toJson());
    return Wallet.fromJson(response);
  }

  Future<void> deleteWallet(String id) async {
    await _apiService.delete('/wallets/$id');
  }

  // Transactions
  Future<List<Transaction>> getTransactions({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    String url = '/transactions';
    
    // Construir la URL con parámetros de consulta manualmente
    List<String> params = [];
    if (walletId != null) params.add('walletId=$walletId');
    if (startDate != null) params.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null) params.add('endDate=${endDate.toIso8601String()}');
    if (type != null) params.add('type=${type.toString().split('.').last.toUpperCase()}');
    
    if (params.isNotEmpty) {
      url += '?' + params.join('&');
    }
    
    final response = await _apiService.get(url);
    return (response as List).map((json) => Transaction.fromJson(json)).toList();
  }

  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final response = await _apiService.post('/transactions', data: data);
    return Transaction.fromJson(response);
  }

  // Implement other methods for categories, budgets, and loans...
}
