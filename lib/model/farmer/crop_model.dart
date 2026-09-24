class CropModel {
  const CropModel({
    required this.id,
    required this.farmId,
    required this.name,
    this.fieldId,
    this.variety,
    this.plantingDate,
    this.expectedHarvestDate,
    this.quantityPlanted,
    this.growthStage,
    this.image,
    this.imageUrl,
  });

  final String id;
  final String farmId;
  final String name;

  final String? fieldId;
  final String? variety;

  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;

  final double? quantityPlanted;
  final String? growthStage;

  final String? image;
  final String? imageUrl;

  factory CropModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CropModel(
      id: json['id']?.toString() ?? '',
      farmId: json['farm_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fieldId: json['field_id']?.toString(),
      variety: json['variety']?.toString(),
      plantingDate: _parseDate(
        json['planting_date'],
      ),
      expectedHarvestDate: _parseDate(
        json['expected_harvest_date'],
      ),
      quantityPlanted: _parseDouble(
        json['quantity_planted'],
      ),
      growthStage:
          json['growth_stage']?.toString(),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'field_id': fieldId,
      'name': name,
      'variety': variety,
      'planting_date':
          plantingDate?.toIso8601String(),
      'expected_harvest_date':
          expectedHarvestDate?.toIso8601String(),
      'quantity_planted': quantityPlanted,
      'growth_stage': growthStage,
      'image': image,
      'image_url': imageUrl,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null ||
        value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  DateTime? get plantedAt => plantingDate;

  DateTime? get expectedHarvestAt =>
      expectedHarvestDate;

  String get status =>
      growthStage ?? 'Growing';

  String? get displayImageUrl =>
      imageUrl ?? image;
}