import 'package:get/get.dart';

class NationalIdController extends GetxController {
  final nationalId = ''.obs;
  final isVerified = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> verifyNationalId(String id) async {
    nationalId.value = id;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      isVerified.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  void clearVerification() {
    nationalId.value = '';
    isVerified.value = false;
    errorMessage.value = null;
  }
}