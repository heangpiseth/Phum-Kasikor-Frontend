import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/farmer_model.dart';
import 'package:phum_kasikors/model/farmer/farmer_profile_model.dart';
import 'package:phum_kasikors/model/farmer/user_model.dart';


class FarmerProfileController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final profile = Rxn<FarmerProfileModel>();
  final farmerInfo = Rxn<FarmerModel>();
  final userInfo = Rxn<UserModel>();
  final menuItems = <ProfileMenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeMenuItems();
    loadProfile();
  }

  void _initializeMenuItems() {
    menuItems.assignAll([
      ProfileMenuModel(title: 'Edit Profile', icon: 'assets/icons/edit.svg'),
      ProfileMenuModel(title: 'Farm Management', icon: 'assets/icons/farm.svg'),
      ProfileMenuModel(title: 'Order History', icon: 'assets/icons/order.svg'),
      ProfileMenuModel(title: 'Earnings', icon: 'assets/icons/wallet.svg'),
      ProfileMenuModel(title: 'Settings', icon: 'assets/icons/settings.svg'),
      ProfileMenuModel(title: 'Help & Support', icon: 'assets/icons/help.svg'),
    ]);
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));

      profile.value = FarmerProfileModel(
        name: 'Sok Chanthan',
        role: 'Farmer',
        image: 'assets/images/profile.png',
        products: 48,
        orders: 156,
        rating: 4.8,
      );

      farmerInfo.value = FarmerModel(
        userId: 'user-1',
        farmId: 'farm-1',
        bio: 'Organic rice and vegetable farmer with 10 years of experience.',
        isVerified: true,
      );

      userInfo.value = UserModel(
        id: 'user-1',
        name: 'Sok Chanthan',
        phone: '0987654321',
        role: UserRole.farmer,
        email: 'sokchanthan@email.com',
        imageUrl: 'assets/images/profile.png',
      );

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void editProfile() {
    Get.snackbar(
      'Edit Profile',
      'Navigate to edit profile screen',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToMenu(ProfileMenuModel item) {
    switch (item.title) {
      case 'Edit Profile':
        editProfile();
        break;
      case 'Farm Management':
        Get.snackbar(
          'Farm Management',
          'Navigate to farm management screen',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'Order History':
        Get.snackbar(
          'Order History',
          'Navigate to order history screen',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'Earnings':
        Get.snackbar(
          'Earnings',
          'Navigate to earnings screen',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'Settings':
        Get.snackbar(
          'Settings',
          'Navigate to settings screen',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'Help & Support':
        Get.snackbar(
          'Help & Support',
          'Navigate to help & support screen',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      default:
        break;
    }
  }

  void logout() {
    Get.snackbar(
      'Logout',
      'Logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
