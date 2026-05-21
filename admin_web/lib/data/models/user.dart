class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:              json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name:            (json['name']  as String?) ?? '',      // ✅ was: json['name']
      email:           (json['email'] as String?) ?? '',      // ✅ was: json['email']
      role:            (json['role']  as String?) ?? 'user',
      isActive:        json['is_active'] == true || json['is_active'] == 1,
      emailVerifiedAt: json['email_verified_at'] != null
                         ? DateTime.tryParse(json['email_verified_at'] as String)
                         : null,
      createdAt:       json['created_at'] != null
                         ? DateTime.tryParse(json['created_at'] as String)
                         : null,
      updatedAt:       json['updated_at'] != null
                         ? DateTime.tryParse(json['updated_at'] as String)
                         : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                id,
    'name':              name,
    'email':             email,
    'role':              role,
    'is_active':         isActive,
    'email_verified_at': emailVerifiedAt?.toIso8601String(),
    'created_at':        createdAt?.toIso8601String(),
    'updated_at':        updatedAt?.toIso8601String(),
  };
}