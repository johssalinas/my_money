enum CategoryType { income, expense, transfer, loan }

class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final CategoryType type;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.type,
    required this.isDefault,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      type: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['type'],
      ),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'type': type.toString().split('.').last.toUpperCase(),
      'isDefault': isDefault,
    };
  }
}
