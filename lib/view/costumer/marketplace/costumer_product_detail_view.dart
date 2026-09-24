import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_product_detail_controller.dart';

class CostumerProductDetailView extends GetView<ProductDetailController> {
  const CostumerProductDetailView({super.key});

  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFF7F8F3);
  static const Color border = Color(0xFFE1E7DE);

  @override
  Widget build(BuildContext context) {
    final product = controller.product;

    return Scaffold(
      backgroundColor: cream,
      body: CustomScrollView(
        slivers: [
          _buildImageHeader(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 18),
                  _buildFarmCard(),
                  const SizedBox(height: 18),
                  _buildInfoRow(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildReviews(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ============================================================
  // IMAGE HEADER
  // ============================================================

  Widget _buildImageHeader(BuildContext context) {
    final product = controller.product;
    final imageUrl = product.imageUrl;

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      elevation: 0,
      backgroundColor: green,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _roundButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Get.back(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _roundButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {
              Get.snackbar(
                'Favorites',
                'Favorite feature coming soon.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _imagePlaceholder();
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return _imagePlaceholder(
                    loading: true,
                  );
                },
              )
            else
              _imagePlaceholder(),

            // Bottom gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 18,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      size: 15,
                      color: green,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Fresh from local farmers',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: greenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFF7F8F3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(
                color: green,
              )
            : Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 46,
                  color: green,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // PRODUCT HEADER
  // ============================================================

  Widget _buildProductHeader() {
    final product = controller.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263238),
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ratingBadge(),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              product.priceLocal,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: greenDark,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'per ${product.unit}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFFFE082),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 17,
          ),
          const SizedBox(width: 3),
          Text(
            controller.product.rating.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Color(0xFF5D4E00),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM
  // ============================================================

  Widget _buildFarmCard() {
    final product = controller.product;
    final farmName = product.farmName;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: green,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grown by',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  farmName.isEmpty ? 'Local Farmer' : farmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT INFO
  // ============================================================

  Widget _buildInfoRow() {
    final product = controller.product;

    return Row(
      children: [
        Expanded(
          child: _infoCard(
            icon: Icons.inventory_2_outlined,
            title: 'Available',
            value: '${_formatQuantity(product.quantityAvailable)} ${product.unit}',
            iconColor: green,
            background: greenLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoCard(
            icon: Icons.eco_outlined,
            title: 'Farming',
            value: product.farmingMethod?.isNotEmpty == true
                ? product.farmingMethod!
                : 'Local',
            iconColor: const Color(0xFF795548),
            background: const Color(0xFFEFEBE9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoCard(
            icon: Icons.category_outlined,
            title: 'Category',
            value: product.category?.name ?? 'Produce',
            iconColor: const Color(0xFF1976D2),
            background: const Color(0xFFE3F2FD),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color background,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 105,
      ),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    final description = controller.product.description.trim();

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      title: 'About this product',
      icon: Icons.info_outline_rounded,
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          height: 1.55,
          color: Color(0xFF546E7A),
        ),
      ),
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Widget _buildReviews() {
    return Obx(() {
      final reviews = controller.reviews;

      return _sectionCard(
        title: 'Customer reviews',
        icon: Icons.star_outline_rounded,
        trailing: reviews.isEmpty
            ? null
            : Text(
                '${reviews.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
        child: reviews.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'No reviews yet. Be the first to review this product.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: reviews
                    .take(3)
                    .map(_reviewTile)
                    .toList(),
              ),
      );
    });
  }

  Widget _reviewTile(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: greenLight,
            child: const Icon(
              Icons.person_rounded,
              color: green,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reviewName(review),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _reviewComment(review),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _reviewName(dynamic review) {
    try {
      final user = review.user;

      if (user != null && user.name != null) {
        return user.name.toString();
      }
    } catch (_) {}

    return 'Customer';
  }

  String _reviewComment(dynamic review) {
    try {
      final comment = review.comment;

      if (comment != null && comment.toString().trim().isNotEmpty) {
        return comment.toString();
      }
    } catch (_) {}

    try {
      final comment = review.review;

      if (comment != null && comment.toString().trim().isNotEmpty) {
        return comment.toString();
      }
    } catch (_) {}

    return 'Great product from a local farmer.';
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM CART BAR
  // ============================================================

  Widget _buildBottomBar() {
    return Obx(() {
      final quantity = controller.quantity.value;
      final total = controller.totalPrice;
      final available = controller.product.quantityAvailable;

      final canAdd = available >= quantity && available > 0;

      return Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: border,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _quantitySelector(),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canAdd
                        ? controller.addToCart
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      disabledBackgroundColor:
                          Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            available <= 0
                                ? 'Out of stock'
                                : 'Add • ${_formatPrice(total)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _quantitySelector() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: greenLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.decrement,
            icon: const Icon(
              Icons.remove_rounded,
              size: 19,
              color: greenDark,
            ),
          ),
          Obx(
            () => Text(
              '${controller.quantity.value}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: greenDark,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.increment,
            icon: const Icon(
              Icons.add_rounded,
              size: 19,
              color: greenDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}