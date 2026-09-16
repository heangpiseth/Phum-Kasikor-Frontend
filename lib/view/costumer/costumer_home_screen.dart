import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_home_model.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_card.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_card.dart';
import 'package:phum_kasikors/widgets/ai_assistant/ai_assistant_compact_card.dart';

class CostumerHomeScreen extends StatelessWidget {
  CostumerHomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final CartController cart = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _greeting(),
              const SizedBox(height: 18),
              _search(),
              const SizedBox(height: 14),
              _categories(),
              const SizedBox(height: 22),
              const AiAssistantCompactCard(isFarmer: false),
              const SizedBox(height: 22),

              _sectionHeader(
                'Featured Farms',
                onSeeAll: () {
                  Get.snackbar(
                    'Featured Farms',
                    'All farms will be available soon.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const SizedBox(height: 10),
              _featuredFarms(),
              const SizedBox(height: 22),

              _sectionHeader('Fresh Today'),
              const SizedBox(height: 10),
              _freshToday(),
              const SizedBox(height: 22),

              _sectionHeader('Near You'),
              const SizedBox(height: 10),
              _nearYou(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // GREETING
  // ===========================================================

  Widget _greeting() {
    return Obx(() {
      final user = controller.user.value;

      return Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.divider,
            backgroundImage:
                user.avatarUrl.isEmpty ? null : NetworkImage(user.avatarUrl),
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        user.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Get.snackbar(
                    'Notifications',
                    'No new notifications',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
              if (user.hasNotification)
                Positioned(
                  right: 10,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  // ===========================================================
  // SEARCH
  // ===========================================================

  Widget _search() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: controller.goToSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search fresh farms & produce...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: controller.openFilter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // CATEGORIES
  // ===========================================================

  Widget _categories() {
    return Obx(
      () => SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (_, index) {
            final category = controller.categories[index];
            final selected = controller.selectedFilter.value == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                onSelected: (_) => controller.setFilter(category),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================
  // FEATURED FARMS
  // ===========================================================

  Widget _featuredFarms() {
    return Obx(() {
      if (controller.featuredFarms.isEmpty) {
        return const SizedBox(
          height: 140,
          child: Center(child: Text('No featured farms')),
        );
      }

      return SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.featuredFarms.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, index) {
            final FarmModel farm = controller.featuredFarms[index];
            return FarmCard(
              farm: farm,
              onTap: () => controller.openFarm(farm),
            );
          },
        ),
      );
    });
  }

  // ===========================================================
  // FRESH TODAY
  // ===========================================================

  Widget _freshToday() {
    return Obx(() {
      if (controller.freshToday.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No products available')),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.freshToday.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (_, index) {
          final ProductModel product = controller.freshToday[index];
          return ProductCard(
            product: product,
            onTap: () => controller.openProduct(product),
            onAdd: () => cart.addProduct(product, quantity: 1),
          );
        },
      );
    });
  }

  // ===========================================================
  // NEAR YOU
  // ===========================================================

  Widget _nearYou() {
    return Obx(() {
      if (controller.nearYou.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No farms near you'),
          ),
        );
      }

      return Column(
        children: controller.nearYou.map((farm) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: () => controller.openNearbyFarm(farm),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  farm.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.divider,
                    child: const Icon(Icons.agriculture),
                  ),
                ),
              ),
              title: Text(
                farm.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${farm.distanceKm} km away • '
                '${farm.liveProducts} live products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${farm.rating} ★',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ===========================================================
  // SECTION HEADER
  // ===========================================================

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
