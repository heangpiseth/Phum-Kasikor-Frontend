class HarvestLogModel {
  const HarvestLogModel({
    required this.id,
    required this.farmId,
    required this.cropId,
    required this.harvestDate,
    required this.quantity,
    required this.quality,
    required this.condition,
    this.fieldId,
    this.notes,
    this.cropName,
    this.fieldName,
  });

  final String id;
  final String farmId;
  final String cropId;
  final String? fieldId;

  final DateTime harvestDate;
  final double quantity;

  final String quality;
  final String condition;

  final String? notes;

  // Loaded from Laravel relationships.
  final String? cropName;
  final String? fieldName;

  factory HarvestLogModel.fromJson(Map<String, dynamic> json) {
    final crop = json['crop'] is Map<String, dynamic>
        ? json['crop'] as Map<String, dynamic>
        : null;

    final field = json['field'] is Map<String, dynamic>
        ? json['field'] as Map<String, dynamic>
        : null;

    return HarvestLogModel(
      id: json['id'].toString(),
      farmId: json['farm_id'].toString(),
      cropId: json['crop_id'].toString(),
      fieldId: json['field_id']?.toString(),
      harvestDate: DateTime.tryParse(
            json['harvest_date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      quantity: _toDouble(json['quantity']),
      quality: json['quality']?.toString() ?? 'good',
      condition: json['condition']?.toString() ?? 'fresh',
      notes: json['notes']?.toString(),
      cropName: crop?['name']?.toString(),
      fieldName: field?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'crop_id': cropId,
      'field_id': fieldId,
      'harvest_date': _dateOnly(harvestDate),
      'quantity': quantity,
      'quality': quality,
      'condition': condition,
      'notes': notes,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String get qualityLabel {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Poor';
      default:
        return quality;
    }
  }

  String get conditionLabel {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return 'Fresh';
      case 'good':
        return 'Good';
      case 'damaged':
        return 'Damaged';
      default:
        return condition;
    }
  }
}