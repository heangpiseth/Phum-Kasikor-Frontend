import 'package:get/get.dart';

class ProfileMenuItem {
  final String label;
  final String icon; // material icon name resolved in the view
  final int? badge;
  const ProfileMenuItem(this.label, this.icon, {this.badge});

  factory ProfileMenuItem.fromKey(String key, {int? badge}) =>
      ProfileMenuItem(key, key, badge: badge);
}

class ProfileController extends GetxController {
  final userName = 'Channa Sok'.obs;
  final memberSince = 'July 2024'.obs;
  final location = 'Phnom Penh, Cambodia'.obs;
  final avatarUrl = 'https://i.pravatar.cc/150?img=47'.obs;

  final ordersCount = 12.obs;
  final favoritesCount = 8.obs;
  final reviewsCount = 5.obs;

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