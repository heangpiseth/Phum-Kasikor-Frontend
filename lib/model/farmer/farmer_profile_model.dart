class FarmerProfileModel {
  const FarmerProfileModel({
    required this.name,
    this.displayName,
    this.role,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.image,
    this.products = 0,
    this.orders = 0,
    this.rating = 0,
    this.isVerified = false,
  });

  final String name;
  final String? displayName;
  final String? role;
  final String? bio;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? image;

  final int products;
  final int orders;
  final double rating;

  final bool isVerified;

  factory FarmerProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FarmerProfileModel(
      name: json['name']?.toString() ?? '',
      displayName:
          json['display_name']?.toString(),
      role: json['role']?.toString(),
      bio: json['bio']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth:
          _parseDate(json['date_of_birth']),
      image:
          json['profile_image']?.toString(),
      products:
          _toInt(json['products']),
      orders:
          _toInt(json['orders']),
      rating:
          _toDouble(json['rating']),
      isVerified:
          _parseBool(
        json['is_verified'],
      ),
    );
  }

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static bool _parseBool(dynamic value) {
    if (value == true || value == 1) {
      return true;
    }

    if (value is String) {
      return value.toLowerCase() ==
              'true' ||
          value == '1';
    }

    return false;
  }
}