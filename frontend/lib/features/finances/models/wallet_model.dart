class Wallet {
  final String id;
  final String name;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final bool isDefault;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    required this.isDefault,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      balance: json['balance'].toDouble(),
      currency: json['currency'],
      icon: json['icon'],
      color: json['color'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
    };
  }
}
