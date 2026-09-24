class FarmModel {
  final int id;
  final int userId;
  final String farmName;
  final String description;
  final String location;
  final double farmSize;
  final String farmingMethod;
  final double? latitude;
  final double? longitude;
  final String? coverImage;

  FarmModel({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.description,
    required this.location,
    required this.farmSize,
    required this.farmingMethod,
    this.latitude,
    this.longitude,
    this.coverImage,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      userId: json['user_id'],
      farmName: json['farm_name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      farmSize: double.tryParse(json['farm_size'].toString()) ?? 0,
      farmingMethod: json['farming_method'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      coverImage: json['cover_image'],
    );
  }

  String get imageUrl => coverImage ?? '';
  String get name => farmName;
  double get rating => 4.5;
  double get distanceKm => 0.0;
}