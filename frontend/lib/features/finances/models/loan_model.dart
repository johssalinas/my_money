class Loan {
  final String id;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final bool isPaid;
  final bool isGiven;
  final String personName;
  final String walletId;
  final String walletName;

  Loan({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.dueDate,
    required this.isPaid,
    required this.isGiven,
    required this.personName,
    required this.walletId,
    required this.walletName,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isPaid: json['isPaid'],
      isGiven: json['isGiven'],
      personName: json['personName'],
      walletId: json['wallet']['id'],
      walletName: json['wallet']['name'],
    );
  }
}
