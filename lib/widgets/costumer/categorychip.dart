import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: selected ? Colors.white : AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}