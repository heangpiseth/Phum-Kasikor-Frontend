import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';

class FarmerProductCard extends StatelessWidget {
  const FarmerProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F6E9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Icon(
                _iconFor(product.name),
                color: AppColors.primary,
                size: 45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${product.price.toStringAsFixed(2)}/${product.unit}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${product.stock} ${product.unit}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    _AvailabilityBadge(inStock: product.isInStock),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  IconData _iconFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('rice')) return Icons.rice_bowl_outlined;
    if (value.contains('mango') || value.contains('fruit')) {
      return Icons.apple_outlined;
    }
    if (value.contains('vegetable') || value.contains('morning')) {
      return Icons.eco_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.inStock});
  final bool inStock;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: inStock ? AppColors.primaryLight : const Color(0xFFFDE8E7),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      inStock ? 'Active' : 'Sold out',
      style: TextStyle(
        color: inStock ? AppColors.primary : AppColors.error,
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
