class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}
