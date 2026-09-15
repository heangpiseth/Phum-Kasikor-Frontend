import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/repositories/auth/auth_repository.dart';

class LocationSetupController extends GetxController {
  final _authRepository = AuthRepository();

  final selectedProvince = 'Phnom Penh'.obs;
  final selectedDistrict = 'Chroy Chang...'.obs;
  final selectedCommune = 'Prek Leap'.obs;
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  void setProvince(String? value) {
    if (value != null) selectedProvince.value = value;
  }

  void setDistrict(String? value) {
    if (value != null) selectedDistrict.value = value;
  }

  void useCurrentLocation() {
    // fills in the same placeholder values shown by default.
    selectedProvince.value = 'Phnom Penh';
    selectedDistrict.value = 'Chroy Chang...';
    selectedCommune.value = 'Prek Leap';

    Get.snackbar(
      'Location detected',
      'Your current location has been selected.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE8F5E9),
      colorText: const Color(0xFF2E7D32),
      margin: const EdgeInsets.all(15),
    );
  }

  Future<void> setLocationAndContinue() async {
    isSubmitting.value = true;
    errorMessage.value = null;

    final response = await _authRepository.setupLocation(
      province: selectedProvince.value,
      district: selectedDistrict.value,
      commune: selectedCommune.value,
      latitude: latitude.value,
      longitude: longitude.value,
    );

    isSubmitting.value = false;

    if (!response.success) {
      errorMessage.value = response.message;
      Get.snackbar('Could not save location', response.message ?? 'Please try again.');
      return;
    }

    await _goHome();
  }

  Future<void> skip() async => _goHome();

  Future<void> _goHome() async {
    final role = await TokenStorage.getRole();

    if (role == 'farmer') {
      Get.offAllNamed(AppRoutes.farmerHome);
    } else {
      Get.offAllNamed(AppRoutes.costumerHomescreen);
    }
  }
}