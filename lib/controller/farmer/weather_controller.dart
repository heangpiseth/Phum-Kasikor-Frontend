import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/weather_model.dart';

class WeatherController extends GetxController {
  final Rxn<WeatherModel> weather = Rxn<WeatherModel>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/weather',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid weather response.');
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Unable to load weather.',
        );
      }

      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Weather data is missing.');
      }

      weather.value = WeatherModel.fromJson(data);
    } catch (e) {
      errorMessage.value = e
          .toString()
          .replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWeather() async {
    await loadWeather();
  }

  String get weatherDescription {
    final code = weather.value?.current.weatherCode;

    if (code == null) {
      return 'Unknown';
    }

    return _weatherDescription(code);
  }

  String get weatherIcon {
    final code = weather.value?.current.weatherCode;

    if (code == null) {
      return '☁️';
    }

    return _weatherIcon(code);
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Clear sky';

    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';

    if (code >= 45 && code <= 48) {
      return 'Foggy';
    }

    if (code >= 51 && code <= 57) {
      return 'Drizzle';
    }

    if (code >= 61 && code <= 67) {
      return 'Rain';
    }

    if (code >= 71 && code <= 77) {
      return 'Snow';
    }

    if (code >= 80 && code <= 82) {
      return 'Rain showers';
    }

    if (code >= 85 && code <= 86) {
      return 'Snow showers';
    }

    if (code >= 95 && code <= 99) {
      return 'Thunderstorm';
    }

    return 'Unknown';
  }

  String _weatherIcon(int code) {
    if (code == 0) return '☀️';

    if (code == 1) return '🌤️';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';

    if (code >= 45 && code <= 48) {
      return '🌫️';
    }

    if (code >= 51 && code <= 57) {
      return '🌦️';
    }

    if (code >= 61 && code <= 67) {
      return '🌧️';
    }

    if (code >= 71 && code <= 77) {
      return '❄️';
    }

    if (code >= 80 && code <= 82) {
      return '🌦️';
    }

    if (code >= 85 && code <= 86) {
      return '🌨️';
    }

    if (code >= 95 && code <= 99) {
      return '⛈️';
    }

    return '☁️';
  }
}