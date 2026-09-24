class WeatherModel {
  final FarmWeatherLocation farm;
  final CurrentWeather current;
  final List<DailyWeather> daily;

  WeatherModel({
    required this.farm,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // ------------------------------------------------------------
    // SUPPORT BOTH:
    //
    // 1. { farm: ..., weather: ... }
    //
    // 2. { data: { farm: ..., weather: ... } }
    // ------------------------------------------------------------

    Map<String, dynamic> root = json;

    if (json['data'] is Map) {
      root = Map<String, dynamic>.from(
        json['data'],
      );
    }

    final weatherJson =
        root['weather'] is Map
            ? Map<String, dynamic>.from(
                root['weather'],
              )
            : <String, dynamic>{};

    final currentJson =
        weatherJson['current'] is Map
            ? Map<String, dynamic>.from(
                weatherJson['current'],
              )
            : <String, dynamic>{};

    final dailyJson =
        weatherJson['daily'] is Map
            ? Map<String, dynamic>.from(
                weatherJson['daily'],
              )
            : <String, dynamic>{};

    // ------------------------------------------------------------
    // DAILY DATA
    // ------------------------------------------------------------

    final times = _toStringList(
      dailyJson['time'],
    );

    final weatherCodes = _toList(
      dailyJson['weather_code'],
    );

    final maxTemps = _toList(
      dailyJson['temperature_max'],
    );

    final minTemps = _toList(
      dailyJson['temperature_min'],
    );

    final rainSums = _toList(
      dailyJson['rain_sum'],
    );

    final precipitationSums = _toList(
      dailyJson['precipitation_sum'],
    );

    final rainProbabilities = _toList(
      dailyJson['rain_probability'],
    );

    final count = times.length;

    final daily = List.generate(
      count,
      (index) {
        return DailyWeather(
          date: times[index],
          weatherCode: _toInt(
            weatherCodes,
            index,
          ),
          maxTemperature: _toDouble(
            maxTemps,
            index,
          ),
          minTemperature: _toDouble(
            minTemps,
            index,
          ),
          rainMm: _toDouble(
            rainSums,
            index,
          ),
          precipitationMm: _toDouble(
            precipitationSums,
            index,
          ),
          rainProbability: _toDouble(
            rainProbabilities,
            index,
          ),
          maxWindKmh: 0,
        );
      },
    );

    // ------------------------------------------------------------
    // DEBUG
    // ------------------------------------------------------------

    print(
      'WEATHER MODEL ROOT: $root',
    );

    print(
      'WEATHER MODEL CURRENT: $currentJson',
    );

    print(
      'WEATHER TEMPERATURE: ${currentJson['temperature']}',
    );

    print(
      'WEATHER HUMIDITY: ${currentJson['humidity']}',
    );

    print(
      'WEATHER RAIN: ${currentJson['rainfall_mm']}',
    );

    print(
      'WEATHER RAIN PROBABILITY: ${currentJson['rain_probability']}',
    );

    // ------------------------------------------------------------
    // MODEL
    // ------------------------------------------------------------

    return WeatherModel(
      farm: FarmWeatherLocation.fromJson(
        root['farm'] is Map
            ? Map<String, dynamic>.from(
                root['farm'],
              )
            : <String, dynamic>{},
      ),
      current: CurrentWeather.fromJson(
        currentJson,
      ),
      daily: daily,
    );
  }

  static List<dynamic> _toList(
    dynamic value,
  ) {
    if (value is List) {
      return List<dynamic>.from(value);
    }

    return <dynamic>[];
  }

  static List<String> _toStringList(
    dynamic value,
  ) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map(
          (item) => item?.toString() ?? '',
        )
        .toList();
  }

  static int _toInt(
    List<dynamic> list,
    int index,
  ) {
    if (index >= list.length) {
      return 0;
    }

    final value = list[index];

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

  static double _toDouble(
    List<dynamic> list,
    int index,
  ) {
    if (index >= list.length) {
      return 0;
    }

    final value = list[index];

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
}

// ============================================================
// FARM
// ============================================================

class FarmWeatherLocation {
  final int? id;
  final String? name;
  final String? location;
  final double? latitude;
  final double? longitude;

  FarmWeatherLocation({
    this.id,
    this.name,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory FarmWeatherLocation.fromJson(
    Map<String, dynamic> json,
  ) {
    return FarmWeatherLocation(
      id: _toIntNullable(
        json['id'],
      ),
      name: json['name']?.toString(),
      location: json['location']?.toString(),
      latitude: _number(
        json['latitude'],
      ),
      longitude: _number(
        json['longitude'],
      ),
    );
  }

  static int? _toIntNullable(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double? _number(
    dynamic value,
  ) {
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
}

// ============================================================
// CURRENT WEATHER
// ============================================================

class CurrentWeather {
  final String? time;
  final double? temperatureC;
  final double? humidityPercent;
  final double? rainMm;
  final double? precipitationMm;
  final double? windKmh;
  final int weatherCode;
  final double? rainProbability;
  final bool? isDay;

  CurrentWeather({
    this.time,
    this.temperatureC,
    this.humidityPercent,
    this.rainMm,
    this.precipitationMm,
    this.windKmh,
    required this.weatherCode,
    this.rainProbability,
    this.isDay,
  });

  factory CurrentWeather.fromJson(
    Map<String, dynamic> json,
  ) {
    return CurrentWeather(
      time: json['time']?.toString(),

      temperatureC: _number(
        json['temperature'],
      ),

      humidityPercent: _number(
        json['humidity'],
      ),

      rainMm: _number(
        json['rainfall_mm'],
      ),

      precipitationMm: _number(
        json['rainfall_mm'],
      ),

      windKmh: _number(
        json['wind_speed'],
      ),

      weatherCode: _toInt(
        json['weather_code'],
      ),

      rainProbability: _number(
        json['rain_probability'],
      ),

      isDay: json['is_day'] is num
          ? (json['is_day'] as num).toInt() == 1
          : null,
    );
  }

  static double? _number(
    dynamic value,
  ) {
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

  static int _toInt(
    dynamic value,
  ) {
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
}

// ============================================================
// DAILY WEATHER
// ============================================================

class DailyWeather {
  final String date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final double rainMm;
  final double precipitationMm;
  final double rainProbability;
  final double maxWindKmh;

  DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.rainMm,
    required this.precipitationMm,
    required this.rainProbability,
    required this.maxWindKmh,
  });
}