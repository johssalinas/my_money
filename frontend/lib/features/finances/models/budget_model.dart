enum BudgetType { weekly, monthly }

class BudgetItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final double amount;
  final double spent;

  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spent,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'],
      categoryId: json['category']['id'],
      categoryName: json['category']['name'],
      amount: json['amount'].toDouble(),
      spent: json['spent'].toDouble(),
    );
  }
}

class Budget {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetType type;
  final String walletId;
  final String walletName;
  final List<BudgetItem> items;

  Budget({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.walletId,
    required this.walletName,
    required this.items,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      type: BudgetType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['type'],
      ),
      walletId: json['wallet']['id'],
      walletName: json['wallet']['name'],
      items:
          (json['items'] as List)
              .map((item) => BudgetItem.fromJson(item))
              .toList(),
    );
  }
}
