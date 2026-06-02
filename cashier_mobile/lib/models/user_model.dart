class UserModel {
  final int id;
  final String name;
  final String email;
  final String token;
  final String role; // ← added

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role, // ← added
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      token: json['token'],
      role: json['user']['role'] ?? 'cashier', // ← added
    );
  }
}