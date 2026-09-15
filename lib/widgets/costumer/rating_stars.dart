// rating_stars.dart
import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: size),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: size * 0.8, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}