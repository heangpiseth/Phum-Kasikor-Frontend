class WateringRecommendationModel {
  final CropInfo crop;
  final WeatherInfo weather;
  final WateringInfo watering;
  final HarvestInfo harvest;
  final RelationshipInfo relationship;

  WateringRecommendationModel({
    required this.crop,
    required this.weather,
    required this.watering,
    required this.harvest,
    required this.relationship,
  });

  factory WateringRecommendationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WateringRecommendationModel(
      crop: CropInfo.fromJson(
        json['crop'] ?? {},
      ),
      weather: WeatherInfo.fromJson(
        json['weather'] ?? {},
      ),
      watering: WateringInfo.fromJson(
        json['watering'] ?? {},
      ),
      harvest: HarvestInfo.fromJson(
        json['harvest'] ?? {},
      ),
      relationship: RelationshipInfo.fromJson(
        json['relationship'] ?? {},
      ),
    );
  }
}

class CropInfo {
  final dynamic id;
  final String name;
  final String growthStage;
  final String? plantingDate;
  final int? daysAfterPlanting;

  CropInfo({
    required this.id,
    required this.name,
    required this.growthStage,
    this.plantingDate,
    this.daysAfterPlanting,
  });

  factory CropInfo.fromJson(Map<String, dynamic> json) {
    return CropInfo(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      growthStage:
          json['growth_stage']?.toString() ?? 'unknown',
      plantingDate:
          json['planting_date']?.toString(),
      daysAfterPlanting:
          json['days_after_planting'] == null
              ? null
              : int.tryParse(
                  json['days_after_planting'].toString(),
                ),
    );
  }
}

class WeatherInfo {
  final double temperature;
  final double rainfallMm;
  final double rainProbability;

  WeatherInfo({
    required this.temperature,
    required this.rainfallMm,
    required this.rainProbability,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      temperature: _toDouble(json['temperature']),
      rainfallMm: _toDouble(json['rainfall_mm']),
      rainProbability:
          _toDouble(json['rain_probability']),
    );
  }
}

class WateringInfo {
  final bool required;
  final double recommendedAmountMm;
  final String timing;
  final String reason;
  final String weatherEffect;

  WateringInfo({
    required this.required,
    required this.recommendedAmountMm,
    required this.timing,
    required this.reason,
    required this.weatherEffect,
  });

  factory WateringInfo.fromJson(Map<String, dynamic> json) {
    return WateringInfo(
      required: json['required'] == true,
      recommendedAmountMm:
          _toDouble(json['recommended_amount_mm']),
      timing: json['timing']?.toString() ?? 'Wait',
      reason: json['reason']?.toString() ?? '',
      weatherEffect:
          json['weather_effect']?.toString() ?? '',
    );
  }
}

class HarvestInfo {
  final bool available;
  final String? estimatedDate;
  final int? daysRemaining;
  final String growthStage;
  final int? harvestDays;

  final String source;
  final bool isHarvested;
  final String? actualHarvestDate;
  final dynamic quantity;
  final String? quality;
  final String? condition;
  final String? notes;

  HarvestInfo({
    required this.available,
    this.estimatedDate,
    this.daysRemaining,
    required this.growthStage,
    this.harvestDays,
    required this.source,
    required this.isHarvested,
    this.actualHarvestDate,
    this.quantity,
    this.quality,
    this.condition,
    this.notes,
  });

  factory HarvestInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return HarvestInfo(
      available: json['available'] == true,

      estimatedDate:
          json['estimated_date']?.toString(),

      daysRemaining: json['days_remaining'] == null
          ? null
          : int.tryParse(
              json['days_remaining'].toString(),
            ),

      growthStage:
          json['growth_stage']?.toString() ?? 'unknown',

      harvestDays: json['harvest_days'] == null
          ? null
          : int.tryParse(
              json['harvest_days'].toString(),
            ),

      source:
          json['source']?.toString() ?? '',

      isHarvested:
          json['is_harvested'] == true,

      actualHarvestDate:
          json['actual_harvest_date']?.toString(),

      quantity:
          json['quantity'],

      quality:
          json['quality']?.toString(),

      condition:
          json['condition']?.toString(),

      notes:
          json['notes']?.toString(),
    );
  }
}

class RelationshipInfo {
  final bool weatherAffectsWatering;
  final bool cropStageAffectsWatering;
  final bool cropStageAffectsHarvest;
  final bool plantingDateAffectsHarvest;

  RelationshipInfo({
    required this.weatherAffectsWatering,
    required this.cropStageAffectsWatering,
    required this.cropStageAffectsHarvest,
    required this.plantingDateAffectsHarvest,
  });

  factory RelationshipInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return RelationshipInfo(
      weatherAffectsWatering:
          json['weather_affects_watering'] == true,
      cropStageAffectsWatering:
          json['crop_stage_affects_watering'] == true,
      cropStageAffectsHarvest:
          json['crop_stage_affects_harvest'] == true,
      plantingDateAffectsHarvest:
          json['planting_date_affects_harvest'] == true,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}