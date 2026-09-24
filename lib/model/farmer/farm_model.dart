class FarmModel {
  const FarmModel({
    required this.id,
    required this.userId,
    required this.farmName,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.farmSize,
    this.farmingMethod,
    this.coverImage,
  });

  final String id;
  final String userId;

  final String farmName;
  final String? description;
  final String? location;

  final double? latitude;
  final double? longitude;

  final double? farmSize;
  final String? farmingMethod;
  final String? coverImage;

  factory FarmModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FarmModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      farmName: json['farm_name']?.toString() ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      farmSize: _toDouble(json['farm_size']),
      farmingMethod: json['farming_method']?.toString(),
      coverImage: json['cover_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_name': farmName,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'farm_size': farmSize,
      'farming_method': farmingMethod,
      'cover_image': coverImage,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  String get farmSizeLabel {
    if (farmSize == null) {
      return 'Not specified';
    }

    final value = farmSize! % 1 == 0
        ? farmSize!.toStringAsFixed(0)
        : farmSize!.toStringAsFixed(2);

    return '$value ha';
  }

  String get farmingMethodLabel {
    if (farmingMethod == null ||
        farmingMethod!.trim().isEmpty) {
      return 'Not specified';
    }

    return farmingMethod!;
  }
}