enum WateringReminderRepeat {
  daily,
  everyTwoDays,
  everyThreeDays,
}

extension WateringReminderRepeatExtension
    on WateringReminderRepeat {
  String get label {
    switch (this) {
      case WateringReminderRepeat.daily:
        return 'Every day';

      case WateringReminderRepeat.everyTwoDays:
        return 'Every 2 days';

      case WateringReminderRepeat.everyThreeDays:
        return 'Every 3 days';
    }
  }

  int get intervalDays {
    switch (this) {
      case WateringReminderRepeat.daily:
        return 1;

      case WateringReminderRepeat.everyTwoDays:
        return 2;

      case WateringReminderRepeat.everyThreeDays:
        return 3;
    }
  }
}

class WateringReminderModel {
  const WateringReminderModel({
    required this.cropId,
    required this.cropName,
    required this.fieldId,
    required this.fieldName,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.repeat,
  });

  final String cropId;
  final String cropName;

  final String fieldId;
  final String fieldName;

  final bool enabled;

  final int hour;
  final int minute;

  final WateringReminderRepeat repeat;

  WateringReminderModel copyWith({
    String? cropId,
    String? cropName,
    String? fieldId,
    String? fieldName,
    bool? enabled,
    int? hour,
    int? minute,
    WateringReminderRepeat? repeat,
  }) {
    return WateringReminderModel(
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeat: repeat ?? this.repeat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'crop_name': cropName,
      'field_id': fieldId,
      'field_name': fieldName,
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
      'repeat': repeat.name,
    };
  }

  factory WateringReminderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WateringReminderModel(
      cropId: json['crop_id']?.toString() ?? '',
      cropName: json['crop_name']?.toString() ?? '',
      fieldId: json['field_id']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      enabled: json['enabled'] == true,
      hour: _toInt(json['hour']),
      minute: _toInt(json['minute']),
      repeat: _parseRepeat(json['repeat']),
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

  static WateringReminderRepeat _parseRepeat(
    dynamic value,
  ) {
    switch (value?.toString()) {
      case 'everyTwoDays':
        return WateringReminderRepeat.everyTwoDays;

      case 'everyThreeDays':
        return WateringReminderRepeat.everyThreeDays;

      case 'daily':
      default:
        return WateringReminderRepeat.daily;
    }
  }

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0
        ? 12
        : hour % 12;

    final displayMinute =
        minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }
}