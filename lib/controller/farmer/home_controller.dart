import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final stats = <String, dynamic>{}.obs;

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      stats.value = {
        'totalCrops': 12,
        'totalFarms': 3,
        'totalFields': 5,
        'earnings': 1500000,
      };
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
}