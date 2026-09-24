import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_card.dart';
import 'package:phum_kasikors/widgets/ai_assistant/ai_assistant_compact_card.dart';

class CostumerHomeScreen extends StatelessWidget {
  CostumerHomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final CartController cart = Get.put(CartController());

  static const Color background = Color(0xFFF7F8F3);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color green = Color(0xFF2E7D32);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color greenSoft = Color(0xFFF1F8F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: green,
          onRefresh: controller.refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 18),

              _heroBanner(),
              const SizedBox(height: 18),

              _searchBar(),
              const SizedBox(height: 16),

              _categories(),
              const SizedBox(height: 22),

              Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: green,
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _errorCard();
                }

                return const AiAssistantCompactCard(
                  isFarmer: false,
                );
              }),

              const SizedBox(height: 24),

              _sectionHeader(
                title: 'Featured Farms',
                subtitle: 'Meet local farmers',
                onSeeAll: () {
                  Get.snackbar(
                    'Featured Farms',
                    'All farms will be available soon.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const SizedBox(height: 12),

              _featuredFarms(),

              const SizedBox(height: 26),

              _sectionHeader(
                title: 'Fresh Today',
                subtitle: 'Fresh produce from local farms',
              ),
              const SizedBox(height: 12),

              _freshToday(),

              const SizedBox(height: 26),

              _sectionHeader(
                title: 'Near You',
                subtitle: 'Farms around your area',
              ),
              const SizedBox(height: 12),

              _nearYou(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Obx(() {
      final user = controller.user.value;

      if (user == null) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: green,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: user.avatarUrl.isEmpty
                  ? const ColoredBox(
                      color: greenLight,
                      child: Icon(
                        Icons.person,
                        color: green,
                      ),
                    )
                  : Image.network(
                      user.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const ColoredBox(
                          color: greenLight,
                          child: Icon(
                            Icons.person,
                            color: green,
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hello, ${user.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: green,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        user.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      Get.snackbar(
                        'Notifications',
                        user.hasNotification
                            ? 'You have new notifications'
                            : 'No new notifications',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF263238),
                      size: 22,
                    ),
                  ),
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
          ),
        ],
      );
    });
  }

  // ============================================================
  // HERO BANNER
  // ============================================================

  Widget _heroBanner() {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF388E3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: -55,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🌱 LOCAL & FRESH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Fresh from\nCambodian farms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Buy directly from local farmers.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🥬',
                      style: TextStyle(
                        fontSize: 52,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: controller.goToSearch,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: greenLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search farms, fruits, vegetables...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 9),

        GestureDetector(
          onTap: controller.openFilter,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: green.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _categories() {
    return Obx(() {
      return SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (_, index) {
            final category = controller.categories[index];
            final selected =
                controller.selectedFilter.value == category;

            return GestureDetector(
              onTap: () => controller.setFilter(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 76,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? green : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: selected
                        ? green
                        : AppColors.divider,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: green.withValues(alpha: 0.18),
                            blurRadius: 9,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _categoryIcon(category),
                      size: 21,
                      color: selected
                          ? Colors.white
                          : green,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.eco_rounded;
      case 'fruits':
        return Icons.apple_rounded;
      case 'grains':
        return Icons.grass_rounded;
      case 'herbs':
        return Icons.spa_rounded;
      case 'all':
      default:
        return Icons.grid_view_rounded;
    }
  }

  // ============================================================
  // FEATURED FARMS
  // ============================================================

  Widget _featuredFarms() {
    return Obx(() {
      if (controller.featuredFarms.isEmpty) {
        return _emptyCard(
          icon: Icons.agriculture_rounded,
          title: 'No featured farms yet',
          subtitle: 'Check back soon for local farmers.',
        );
      }

      return SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.featuredFarms.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, index) {
            final FarmModel farm =
                controller.featuredFarms[index];

            return GestureDetector(
              onTap: () => controller.openFarm(farm),
              child: Container(
                width: 178,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 9,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: SizedBox(
                        height: 112,
                        width: double.infinity,
                        child: farm.imageUrl.isEmpty
                            ? const ColoredBox(
                                color: greenLight,
                                child: Center(
                                  child: Icon(
                                    Icons.agriculture_rounded,
                                    color: green,
                                    size: 42,
                                  ),
                                ),
                              )
                            : Image.network(
                                farm.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return const ColoredBox(
                                    color: greenLight,
                                    child: Center(
                                      child: Icon(
                                        Icons.agriculture_rounded,
                                        color: green,
                                        size: 42,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        9,
                        12,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            farm.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${farm.rating}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ============================================================
  // FRESH TODAY
  // ============================================================

  Widget _freshToday() {
    return Obx(() {
      final products = _filteredProducts();

      if (products.isEmpty) {
        return _emptyCard(
          icon: Icons.shopping_basket_outlined,
          title: 'No products in this category',
          subtitle: 'Try another category.',
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.60,
        ),
        itemBuilder: (_, index) {
          final ProductModel product = products[index];

          return ProductCard(
            product: product,

            // Tap product card → product detail screen.
            onTap: () => controller.openProduct(product),

            onAdd: () {
              cart.addProduct(
                product,
                quantity: 1,
              );

              Get.snackbar(
                'Added to cart',
                '${product.name} was added to your cart.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: green,
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
          );
        },
      );
    });
  }

  List<ProductModel> _filteredProducts() {
    final selected =
        controller.selectedFilter.value.toLowerCase();

    final all =
        controller.freshToday.toList();

    if (selected == 'all') {
      return all;
    }

    return all.where((product) {
      final category =
          product.category?.name.toLowerCase() ?? '';

      if (selected == 'vegetables') {
        return category.contains('vegetable') ||
            category.contains('leafy');
      }

      if (selected == 'fruits') {
        return category.contains('fruit');
      }

      if (selected == 'grains') {
        return category.contains('grain') ||
            category.contains('rice');
      }

      if (selected == 'herbs') {
        return category.contains('herb');
      }

      return category == selected;
    }).toList();
  }

  // ============================================================
  // NEAR YOU
  // ============================================================

  Widget _nearYou() {
    return Obx(() {
      if (controller.nearYou.isEmpty) {
        return _emptyCard(
          icon: Icons.location_on_outlined,
          title: 'No nearby farms',
          subtitle: 'We will show farms near you here.',
        );
      }

      return Column(
        children: controller.nearYou.map((farm) {
          return GestureDetector(
            onTap: () => controller.openNearbyFarm(farm),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: farm.imageUrl.isEmpty
                          ? const ColoredBox(
                              color: greenLight,
                              child: Icon(
                                Icons.agriculture_rounded,
                                color: green,
                                size: 28,
                              ),
                            )
                          : Image.network(
                              farm.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const ColoredBox(
                                  color: greenLight,
                                  child: Icon(
                                    Icons.agriculture_rounded,
                                    color: green,
                                    size: 28,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: green,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                farm.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 13,
                              color: green,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${farm.distanceKm.toStringAsFixed(1)} km away',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${farm.rating}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: green,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: const [
                Text(
                  'See all',
                  style: TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: green,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: greenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: green,
              size: 25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 34,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          const Text(
            'Could not load the marketplace',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.refreshHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}