import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/repositories/auth/auth_repository.dart';

class ProfileSetupController extends GetxController {
  final _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  final farmNameController = TextEditingController();

  final selectedGender = 'Male'.obs;
  final selectedDate = Rxn<DateTime>();
  final isFarmer = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await TokenStorage.getRole();
    isFarmer.value = role == 'farmer';
  }

  void setGender(String? value) {
    if (value != null) selectedGender.value = value;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> saveAndContinue() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    errorMessage.value = null;

    final response = await _authRepository.setupProfile(
      name: fullNameController.text.trim(),
      displayName: displayNameController.text.trim().isEmpty ? null : displayNameController.text.trim(),
      bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      gender: selectedGender.value,
      dateOfBirth: selectedDate.value,
      farmName: isFarmer.value && farmNameController.text.trim().isNotEmpty
          ? farmNameController.text.trim()
          : null,
    );

    isSubmitting.value = false;

    if (!response.success) {
      errorMessage.value = response.message;
      Get.snackbar('Could not save profile', response.message ?? 'Please try again.');
      return;
    }

    Get.toNamed(AppRoutes.locationSetup);
  }

  void skip() => Get.toNamed(AppRoutes.locationSetup);

  @override
  void onClose() {
    fullNameController.dispose();
    displayNameController.dispose();
    bioController.dispose();
    farmNameController.dispose();
    super.onClose();
  }
}