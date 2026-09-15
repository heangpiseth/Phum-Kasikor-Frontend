import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_farm_detail_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_card.dart';
import 'package:phum_kasikors/widgets/costumer/rating_stars.dart';


class FarmDetailView extends GetView<FarmDetailController> {
  const FarmDetailView({super.key});

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
                              ))
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${controller.farm.province} • Verified Organic Certified ✓',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(controller.farm.description,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        RatingStars(rating: controller.farm.rating),
                        const SizedBox(width: 6),
                        Text('${controller.farm.rating} (${controller.farm.reviewCount} reviews)',
                            style:
                                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Products'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'About'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.products.length,
                    itemBuilder: (_, i) {
                      final p = controller.products[i];
                      return ProductCard(
                        product: (  p as ProductModel),
                        onTap: () => controller.openProduct(p, Get.routing),
                        onAdd: () => cart.addProduct(p as ProductModel),
                      );
                    },
                  )),
              const Center(child: Text('Reviews content here')),
              const Center(child: Text('About content here')),
            ],
          ),
        ),
      ),
    );
  }
}

class   _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}