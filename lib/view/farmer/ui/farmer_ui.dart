import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

class FarmerPage extends StatelessWidget {
  const FarmerPage({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      actions: action == null ? null : [action!],
    ),
    body: SafeArea(child: child),
  );
}

class FarmerTextField extends StatelessWidget {
  const FarmerTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    ),
  );
}
