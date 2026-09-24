enum UserRole {
  farmer,
  customer,
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.imageUrl,
    this.displayName,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.location,
  });

  final String id;
  final String name;
  final String phone;
  final UserRole role;

  final String? email;
  final String? imageUrl;

  final String? displayName;
  final String? bio;
  final String? gender;
  final String? dateOfBirth;
  final String? location;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role']?.toString() ?? 'customer';

    final role = UserRole.values.firstWhere(
      (value) => value.name == roleValue,
      orElse: () => UserRole.customer,
    );

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: role,
      email: json['email']?.toString(),
      imageUrl: json['profile_image']?.toString(),
      displayName: json['display_name']?.toString(),
      bio: json['bio']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      location: json['location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.name,
      'email': email,
      'profile_image': imageUrl,
      'display_name': displayName,
      'bio': bio,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'location': location,
    };
  }
}