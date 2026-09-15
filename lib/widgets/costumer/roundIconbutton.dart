import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

// ignore: unused_element
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}