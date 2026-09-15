import 'package:get/get.dart';

class FarmController extends GetxController {
  final farms = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> fetchFarms() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> addFarm(Map<String, dynamic> farm) async {
    farms.add(farm);
  }

  Future<void> updateFarm(int index, Map<String, dynamic> farm) async {
    if (index >= 0 && index < farms.length) {
      farms[index] = farm;
    }
  }

  Future<void> deleteFarm(int index) async {
    if (index >= 0 && index < farms.length) {
      farms.removeAt(index);
    }
  }
}