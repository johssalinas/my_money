enum TransactionType { income, expense, transfer, loan }

class Transaction {
  final String id;
  final double amount;
  final String? description;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String walletId;
  final String walletName;

  Transaction({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.walletId,
    required this.walletName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['type'],
      ),
      categoryId: json['category']['id'],
      categoryName: json['category']['name'],
      categoryIcon: json['category']['icon'],
      categoryColor: json['category']['color'],
      walletId: json['wallet']['id'],
      walletName: json['wallet']['name'],
    );
  }
}
