enum UserRole { farmer, customer }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? email;
  final String? imageUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: UserRole.values.byName(
        json['role']?.toString() ?? 'customer',
      ),
      email: json['email']?.toString(),
      imageUrl: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.name,
      'email': email,
      'imageUrl': imageUrl,
    };
  }
}