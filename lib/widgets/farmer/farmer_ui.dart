import 'package:flutter/material.dart';

import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerCard extends StatelessWidget {
  const FarmerCard({
    super.key,
    required this.child,
    this.padding = FarmerDesign.cardPadding,
    this.margin, required VoidCallback onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: FarmerDesign.card,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
        boxShadow: FarmerDesign.cardShadow,
      ),
      child: child,
    );
  }
}

class FarmerSectionHeader extends StatelessWidget {
  const FarmerSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FarmerDesign.heading3,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: FarmerDesign.caption,
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: FarmerDesign.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
            ),
            child: Text(
              actionLabel!,
              style: FarmerDesign.button.copyWith(
                color: FarmerDesign.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class FarmerStatusBadge extends StatelessWidget {
  const FarmerStatusBadge({
    super.key,
    required this.label,
    this.color = FarmerDesign.primary,
    this.backgroundColor = FarmerDesign.primaryLight,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class FarmerStatCard extends StatelessWidget {
  const FarmerStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color = FarmerDesign.primary,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FarmerCard(
      padding: const EdgeInsets.all(14),
      onTap: () {  },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: FarmerDesign.heading2,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: FarmerDesign.caption,
          ),
        ],
      ),
    );
  }
}

class FarmerQuickAction extends StatelessWidget {
  const FarmerQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = FarmerDesign.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        FarmerDesign.radiusMedium,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: FarmerDesign.card,
          borderRadius: BorderRadius.circular(
            FarmerDesign.radiusMedium,
          ),
          border: Border.all(
            color: FarmerDesign.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: FarmerDesign.bodyMedium,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: FarmerDesign.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

class FarmerEmptyState extends StatelessWidget {
  const FarmerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FarmerCard(
      onTap: () {  },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: FarmerDesign.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FarmerDesign.heading3,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FarmerDesign.caption,
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmerDesign.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}

class FarmerLoadingCard extends StatelessWidget {
  const FarmerLoadingCard({
    super.key,
    this.height = 120,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: FarmerDesign.card,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: FarmerDesign.primary,
        ),
      ),
    );
  }
}

class FarmerPrimaryButton extends StatelessWidget {
  const FarmerPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FarmerDesign.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              FarmerDesign.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: FarmerDesign.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FarmerTextField extends StatelessWidget {
  const FarmerTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      style: FarmerDesign.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                color: FarmerDesign.secondaryText,
              ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: FarmerDesign.caption,
        hintStyle: FarmerDesign.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.error,
          ),
        ),
      ),
    );
  }
    // ============================================================
  // COMMON LAYOUT VALUES
  // ============================================================

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  static const Color card = Colors.white;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}