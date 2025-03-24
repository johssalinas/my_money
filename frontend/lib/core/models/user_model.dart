class User {
  final String id;
  final String email;
  final String? name;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Función de utilidad para manejar valores nulos o tipos incorrectos
    T? safeGet<T>(String key, T Function(dynamic) converter) {
      try {
        return json[key] != null ? converter(json[key]) : null;
      } catch (e) {
        print('Error al convertir $key: $e');
        return null;
      }
    }

    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      role: json['role'] ?? 'USER',
      createdAt: safeGet<DateTime>('createdAt', (val) => DateTime.parse(val)),
      updatedAt: safeGet<DateTime>('updatedAt', (val) => DateTime.parse(val)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
