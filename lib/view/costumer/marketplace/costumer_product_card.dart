// product_card.dart
import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

/// Grid-style product card with a quick "+" add-to-cart button,
/// as seen on Explore, Farm Products and Search screens.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const ProductCard({super.key, required this.product, this.onTap, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isLow = product.stock == StockStatus.lowStock;
    final isOut = product.stock == StockStatus.outOfStock;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
                if (isLow || isOut)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOut ? AppColors.error : AppColors.warning,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOut ? 'Out of Stock' : 'Low Stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'In Stock',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.priceLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isOut ? null : onAdd,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isOut
                                ? AppColors.divider
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
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
  }
}
