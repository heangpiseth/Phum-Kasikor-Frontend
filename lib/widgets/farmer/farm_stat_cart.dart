import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

class FarmStatCard extends StatelessWidget {
  const FarmStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 19),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
