import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';


class FarmerProductPreviewScreen extends StatelessWidget {
  const FarmerProductPreviewScreen({super.key, required this.productId});
  final String productId;
  @override
  Widget build(BuildContext context) {
    final products = Get.find<FarmerController>().products;
    final matchingProducts = products.where((item) => item.id == productId);
    if (matchingProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Preview')),
        body: const Center(child: Text('Product not found.')),
      );
    }
    final product = matchingProducts.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Preview',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            _ProductHero(product: product),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.verified, size: 17, color: AppColors.success),
                const SizedBox(width: 3),
                const Text(
                  '4.8',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Icon(Icons.star, size: 16, color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text:
                        '\$${product.price.toStringAsFixed(2)} / ${product.unit}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: '  (10,000៛/kg)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            const _SellerRow(),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Description',
              child: Text(
                product.description.isEmpty
                    ? 'Premium organic produce harvested with care. Carefully grown using sustainable, pesticide-free methods for fresh flavour and quality.'
                    : product.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailsCard(product: product),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.snackbar(
                      'Edit listing',
                      'Editing will be available soon.',
                    ),
                    child: const Text('Edit Listing'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.snackbar(
                      'Storefront published',
                      '${product.name} is visible to buyers.',
                    ),
                    child: const Text('Publish Storefront'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        colors: [Color(0xFFD9BA85), Color(0xFF9B704B)],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          top: 18,
          child: Icon(Icons.rice_bowl, size: 108, color: Color(0xFFFFF6DD)),
        ),
        Positioned(
          bottom: 16,
          child: Text(
            product.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(blurRadius: 5)],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SellerRow extends StatelessWidget {
  const _SellerRow();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.primaryLight,
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      SizedBox(width: 9),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sokha's Organic Farm",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Text(
            'Kandal Province · Verified Producer',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    ],
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Product details',
    child: Column(
      children: [
        _row(
          'Category',
          product.categoryId == 'grains'
              ? 'Grains & Rice'
              : (product.categoryId ?? 'Fresh produce'),
        ),
        _row('Harvest Date', 'Oct 12, 2024'),
        _row('Minimum Order', '5 ${product.unit}'),
        _row('Farming Method', '100% Organic Certified', last: true),
      ],
    ),
  );
  Widget _row(String label, String value, {bool last = false}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
