import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_add_product_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_product_preview_screen.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';
import 'package:phum_kasikors/widgets/farmer/product_cart.dart';


/// The farmer's own storefront catalogue.
class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return FarmerPage(
      title: 'My Products',
      action: IconButton(
        tooltip: 'Add product',
        icon: const Icon(Icons.add),
        onPressed: () => Get.to(() => const FarmerAddProductScreen()),
      ),
      child: Obx(
        () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Storefront listings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${farmer.products.length} products in your catalogue',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Get.to(() => const FarmerAddProductScreen()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = farmer.products[index];
                  return FarmerProductCard(
                    product: product,
                    onTap: () => Get.to(
                      () => FarmerProductPreviewScreen(productId: product.id),
                    ),
                  );
                }, childCount: farmer.products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .76,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
