import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

class EarningCard extends StatelessWidget {
  const EarningCard({super.key, required this.amount, required this.label});
  final String amount;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
