import 'package:get/get.dart';

class CropController extends GetxController {
  final crops = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> fetchCrops() async {
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

  Future<void> addCrop(Map<String, dynamic> crop) async {
    crops.add(crop);
  }

  Future<void> updateCrop(int index, Map<String, dynamic> crop) async {
    if (index >= 0 && index < crops.length) {
      crops[index] = crop;
    }
  }

  Future<void> deleteCrop(int index) async {
    if (index >= 0 && index < crops.length) {
      crops.removeAt(index);
    }
  }
}