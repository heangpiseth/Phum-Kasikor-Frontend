class WateringModel {
  final int id;
  final int farmId;
  final int? fieldId;

  // IMPORTANT:
  // CropModel.id is String, so cropId must also be String.
  final String cropId;

  final DateTime wateringDate;
  final double? waterAmount;
  final String? notes;

  final CropSummary? crop;
  final FieldSummary? field;

  WateringModel({
    required this.id,
    required this.farmId,
    this.fieldId,
    required this.cropId,
    required this.wateringDate,
    this.waterAmount,
    this.notes,
    this.crop,
    this.field,
  });

  factory WateringModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WateringModel(
      id: _toInt(json['id']),
      farmId: _toInt(json['farm_id']),

      fieldId: json['field_id'] == null
          ? null
          : _toInt(json['field_id']),

      // IMPORTANT:
      // Laravel may return this as int (123)
      // but Flutter keeps it as String ("123").
      cropId: json['crop_id']?.toString() ?? '',

      wateringDate: DateTime.parse(
        json['watering_date'].toString(),
      ),

      waterAmount: json['water_amount'] == null
          ? null
          : _toDouble(json['water_amount']),

      notes: json['notes']?.toString(),

      crop: json['crop'] is Map
          ? CropSummary.fromJson(
              Map<String, dynamic>.from(
                json['crop'],
              ),
            )
          : null,

      field: json['field'] is Map
          ? FieldSummary.fromJson(
              Map<String, dynamic>.from(
                json['field'],
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'field_id': fieldId,
      'crop_id': cropId,
      'watering_date':
          wateringDate.toIso8601String().split('T').first,
      'water_amount': waterAmount,
      'notes': notes,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ============================================================
// CROP SUMMARY
// ============================================================

class CropSummary {
  final int id;
  final String name;
  final String? variety;
  final String? growthStage;
  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;

  CropSummary({
    required this.id,
    required this.name,
    this.variety,
    this.growthStage,
    this.plantingDate,
    this.expectedHarvestDate,
  });

  factory CropSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return CropSummary(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Unknown Crop',
      variety: json['variety']?.toString(),
      growthStage: json['growth_stage']?.toString(),
      plantingDate: _parseDate(
        json['planting_date'],
      ),
      expectedHarvestDate: _parseDate(
        json['expected_harvest_date'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}

// ============================================================
// FIELD SUMMARY
// ============================================================

class FieldSummary {
  final int id;
  final String name;
  final double? area;
  final String? soilType;

  FieldSummary({
    required this.id,
    required this.name,
    this.area,
    this.soilType,
  });

  factory FieldSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return FieldSummary(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Unknown Field',
      area: json['area'] == null
          ? null
          : _toDouble(json['area']),
      soilType: json['soil_type']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}