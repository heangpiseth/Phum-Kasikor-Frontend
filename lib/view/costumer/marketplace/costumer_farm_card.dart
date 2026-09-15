// farm_card.dart
import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/widgets/costumer/rating_stars.dart';

/// Horizontal image card used in "Featured Farms" and "Near You" lists.
class FarmCard extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback? onTap;
  final double width;

  const FarmCard({super.key, required this.farm, this.onTap, this.width = 160});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.4,
                child: Image.network(farm.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              farm.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                RatingStars(rating: farm.rating, size: 12),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${farm.distanceKm}km',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
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