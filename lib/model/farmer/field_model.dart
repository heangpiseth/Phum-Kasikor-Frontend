class FieldModel {
  const FieldModel({
    required this.id,
    required this.farmId,
    required this.name,
    this.area,
    this.soilType,
    this.description,
  });

  final String id;
  final String farmId;
  final String name;
  final double? area;
  final String? soilType;
  final String? description;

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'].toString(),
      farmId: json['farm_id'].toString(),
      name: json['name']?.toString() ?? '',
      area: _toDouble(json['area']),
      soilType: json['soil_type']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'area': area,
      'soil_type': soilType,
      'description': description,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}