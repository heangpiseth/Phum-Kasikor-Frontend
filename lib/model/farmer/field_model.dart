class FieldModel {
  final String id;
  final String farmId;
  final String name;
  final double area; // in hectares
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  FieldModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.area,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  FieldModel copyWith({
    String? id,
    String? farmId,
    String? name,
    double? area,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) {
    return FieldModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      area: area ?? this.area,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farm_id': farmId,
    'name': name,
    'area': area,
    'description': description,
    'image_url': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory FieldModel.fromJson(Map<String, dynamic> json) => FieldModel(
    id: json['id'] as String? ?? '',
    farmId: json['farm_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    area: (json['area'] as num?)?.toDouble() ?? 0.0,
    description: json['description'] as String?,
    imageUrl: json['image_url'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}