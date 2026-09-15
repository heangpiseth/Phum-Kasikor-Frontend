import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_farm_detail_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_card.dart';
import 'package:phum_kasikors/widgets/costumer/rating_stars.dart';

class CostumerFarmDetailView extends GetView<FarmDetailController> {
  const CostumerFarmDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(controller.farm.imageUrl, fit: BoxFit.cover),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(controller.farm.name,
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                        Obx(() => OutlinedButton(
                              onPressed: controller.toggleFollow,
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    controller.isFollowing.value ? Colors.white : AppColors.primary,
                                backgroundColor: controller.isFollowing.value
                                    ? AppColors.primary
                                    : Colors.transparent,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                              child: Text(controller.isFollowing.value ? 'Following' : 'Follow'),
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${controller.farm.province} • Verified Organic Certified ✓',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingStars(
                            rating: controller.farm.rating,
                            reviewCount: controller.farm.reviewCount),
                        const SizedBox(width: 10),
                        Text('${controller.farm.productCount} Followers',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Products'),
                    Tab(text: 'About'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _ProductsTab(controller: controller, cart: cart),
              _AboutTab(controller: controller),
              _ReviewsTab(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final FarmDetailController controller;
  final CartController cart;
  const _ProductsTab({required this.controller, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Obx(() => SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Vegetables', 'Fruits', 'Grains']
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: controller.selectedCategory.value == c,
                            onSelected: (_) => controller.filterByCategory(c),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: controller.selectedCategory.value == c
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            )),
        const SizedBox(height: 8),
        Text('Sorting: ${controller.sortBy.value}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final p = controller.products[i];
                return ProductCard(
                  product: (  p as ProductModel),
                  onTap: () => controller.openProduct(p, Get.routing),
                  onAdd: () => cart.addProduct(p as ProductModel),
                );
              },
            )),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  final FarmDetailController controller;
  const _AboutTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('About this farm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(controller.farm.about.isEmpty
            ? 'No description provided yet.'
            : controller.farm.about),
        const SizedBox(height: 16),
        ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(controller.farm.ownerAvatarUrl)),
          title: Text(controller.farm.ownerName),
          subtitle: const Text('Farmer / Owner'),
          trailing: const Icon(Icons.phone, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final FarmDetailController controller;
  const _ReviewsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.reviews.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final r = controller.reviews[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              RatingStars(rating: r.rating),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(r.comment),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}