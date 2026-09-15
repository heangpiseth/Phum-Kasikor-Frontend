import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_card.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_card.dart';

class CostumerHomeScreen extends GetView<HomeController> {
  const CostumerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =========================
          // GREETING
          // =========================
          Obx(
            () => Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=47',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${controller.userName.value} 👋',
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

                          const SizedBox(width: 2),

                          Expanded(
                            child: Text(
                              controller.userLocation.value,
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

                IconButton(
                  onPressed: () {
                    // TODO: notification screen
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // SEARCH
          // =========================
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.goToSearch(Get.routing),
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
                        Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            'Search fresh farms & produce...',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
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
          ),

          const SizedBox(height: 14),

          // =========================
          // FILTER CHIPS
          // =========================
          Obx(
            () => SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Vegetables', 'Fruits', 'Grains', 'Herbs']
                    .map((filter) {
                      final isSelected =
                          controller.selectedFilter.value == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            controller.setFilter(filter);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // FEATURED FARMS
          // =========================
          _sectionHeader(
            'Featured Farms',
            onSeeAll: () {
              // TODO: open all farms
            },
          ),

          const SizedBox(height: 10),

          Obx(
            () => SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.featuredFarms.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (_, index) {
                  final farm = controller.featuredFarms[index];

                  return FarmCard(
                    farm: farm,
                    onTap: () {
                      controller.openFarm(farm.id , Get.routing);
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // FRESH TODAY
          // =========================
          _sectionHeader('Fresh Today'),

          const SizedBox(height: 10),

          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.freshToday.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, index) {
                final product = controller.freshToday[index];

                return ProductCard(
                  product: product,

                  onTap: () {
                    controller.openProduct(product, Get.routing);
                  },

                  onAdd: () {
                    cart.addProduct(product);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // NEAR YOU
          // =========================
          _sectionHeader('Near You'),

          const SizedBox(height: 10),

          Obx(
            () => Column(
              children: controller.nearYou.map((farm) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () {
                      controller.openFarm(farm.id , Get.routing);
                    },

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        farm.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: AppColors.divider,
                            child: const Icon(Icons.agriculture),
                          );
                        },
                      ),
                    ),

                    title: Text(
                      farm.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: Text(
                      '${farm.distanceKm} km away • '
                      '${farm.productCount} live products',
                    ),

                    trailing: Text('${farm.rating} ★'),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
