import 'package:flutter/material.dart';
import 'package:phum_kasikors/color/color.dart';

const kFarmGreen = AppColors.primary;
const kFarmInk = AppColors.textPrimary;
const kFarmMuted = AppColors.textSecondary;

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.child, this.showBack = false});
  final Widget child;
  final bool showBack;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: showBack
                        ? IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 19,
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: kFarmGreen,
            borderRadius: BorderRadius.circular(size * .3),
          ),
          child: Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: size * .55,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 10),
          const Text(
            'ភូមិកសិករ',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: kFarmGreen,
            ),
          ),
          const Text(
            'PHUM KASIKOR',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              color: kFarmMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthTitle extends StatelessWidget {
  const AuthTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.center = false,
  });
  final String title, subtitle;
  final bool center;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      Text(
        title,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: kFarmInk,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        subtitle,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(fontSize: 13, height: 1.35, color: kFarmMuted),
      ),
    ],
  );
}

class FarmButton extends StatelessWidget {
  const FarmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: kFarmGreen,
              side: const BorderSide(color: kFarmGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: kFarmGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
  );
}

class FarmTextField extends StatelessWidget {
  const FarmTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  // Added for form validation
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kFarmInk,
              ),
            ),

            const SizedBox(height: 6),

            TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,

              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),

                prefixIcon: prefixIcon == null
                    ? null
                    : Icon(
                        prefixIcon,
                        size: 19,
                        color: kFarmGreen,
                      ),

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 13,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class AuthIllustration extends StatelessWidget {
  const AuthIllustration({
    super.key,
    required this.icon,
    this.color = AppColors.primaryLight,
  });
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    width: 160,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Icon(icon, color: kFarmGreen, size: 74),
  );
}
