import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_profile_controller.dart';

class CostumerProfileScreen extends StatelessWidget {
  const CostumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(controller.avatarUrl.value),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    'Member since ${controller.memberSince.value}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      Text(
                        controller.location.value,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                _statCard('Orders', controller.ordersCount.value),
                _statCard('Favorites', controller.favoritesCount.value),
                _statCard('Reviews', controller.reviewsCount.value),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _menuTile(Icons.receipt_long, 'My Orders', badge: 12),
          _menuTile(Icons.favorite_border, 'Favorite Farms'),
          _menuTile(Icons.star_border, 'My Reviews'),
          _menuTile(Icons.location_on_outlined, 'Delivery Addresses'),
          _menuTile(Icons.credit_card, 'Payment Methods'),
          _menuTile(Icons.notifications_none, 'Notification Settings'),
          _menuTile(Icons.language, 'Language (ខ្មែរ)'),
          _menuTile(Icons.help_outline, 'Help & Support'),
          _menuTile(Icons.info_outline, 'About PHUM KASIKOR'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: controller.logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String label, {
    int? badge,
    bool highlight = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: highlight ? AppColors.primary : AppColors.textPrimary,
        ),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
