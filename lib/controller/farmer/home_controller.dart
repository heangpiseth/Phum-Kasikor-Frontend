import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final stats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Dashboard statistics will be populated from the
      // real Farmer controllers instead of fake numbers.
      stats.assignAll({
        'totalCrops': 0,
        'totalFarms': 0,
        'totalFields': 0,
        'earnings': 0.0,
      });
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboard() async {
    await loadDashboard();
  }

  void setStat(String key, dynamic value) {
    stats[key] = value;
  }

  dynamic getStat(String key) {
    return stats[key];
  }

  int get totalCrops {
    final value = stats['totalCrops'];
    return value is num ? value.toInt() : 0;
  }

  int get totalFarms {
    final value = stats['totalFarms'];
    return value is num ? value.toInt() : 0;
  }

  int get totalFields {
    final value = stats['totalFields'];
    return value is num ? value.toInt() : 0;
  }

  double get earnings {
    final value = stats['earnings'];
    return value is num ? value.toDouble() : 0.0;
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}