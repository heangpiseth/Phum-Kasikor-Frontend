import 'package:get/get.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/core/service/customer/customer_service.dart';

class ProfileController extends GetxController {
  final CustomerService _service = CustomerService();

  final userName = ''.obs;
  final memberSince = ''.obs;
  final location = ''.obs;
  final avatarUrl = ''.obs;
  final phone = ''.obs;
  final email = ''.obs;

  final ordersCount = 0.obs;
  final favoritesCount = 0.obs;
  final reviewsCount = 0.obs;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // The profile data can come from the auth controller or a dedicated profile endpoint
      // For now, we'll use a basic implementation
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // Profile data could be fetched from an API endpoint
        // For now using placeholder - replace with real API call when available
        userName.value = 'Customer';
        memberSince.value = DateTime.now().year.toString();
        location.value = 'Cambodia';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      onConfirm: () {
        Get.back();
        // Hook real sign-out / navigation-to-login here.
      },
    );
  }
}