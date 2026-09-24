import 'package:flutter/material.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFF7F8F3);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product.imageUrl;
    final String productName = product.name;
    final String farmName = product.farmName;
    final String price = product.priceLocal;
    final String unit = product.unit;
    final String rating = product.rating.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: greenLight,
        highlightColor: greenLight.withValues(alpha: 0.45),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE4E9E1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // IMAGE
              // ==========================================================

              Expanded(
                flex: 6,
                child: _productImage(imageUrl),
              ),

              // ==========================================================
              // PRODUCT INFO
              // ==========================================================

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    11,
                    9,
                    11,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // --------------------------------------------------
                      // FARM
                      // --------------------------------------------------

                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: greenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.agriculture_rounded,
                              size: 12,
                              color: green,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              farmName.isEmpty
                                  ? 'Local farmer'
                                  : farmName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // --------------------------------------------------
                      // PRICE + RATING
                      // --------------------------------------------------

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: greenDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF5D4E00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        unit.isEmpty ? 'per unit' : 'per $unit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _productImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return _imagePlaceholder(
                  showLoading: true,
                );
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return _imagePlaceholder();
              },
            )
          else
            _imagePlaceholder(),

          // ==========================================================
          // FRESH BADGE
          // ==========================================================

          Positioned(
            top: 9,
            left: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 12,
                    color: green,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Fresh',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: greenDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================================
          // ADD TO CART
          // ==========================================================

          Positioned(
            right: 9,
            bottom: 9,
            child: GestureDetector(
              // Prevent this button from behaving like the
              // product-detail tap.
              onTap: onAdd,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(13),
                  child: Ink(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: green.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder({
    bool showLoading = false,
  }) {
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
        child: showLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: green,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 28,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Fresh produce',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: greenDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}