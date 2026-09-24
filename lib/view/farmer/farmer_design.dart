import 'package:flutter/material.dart';

class FarmerDesign {
  FarmerDesign._();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFFF7F8F3);

  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFFE8F5E9);

  static const Color secondary = Color(0xFF66BB6A);
  static const Color secondaryLight = Color(0xFFC8E6C9);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  static const Color white = Colors.white;
  static const Color black = Color(0xFF1B1B1B);

  static const Color text = Color(0xFF263238);
  static const Color secondaryText = Color(0xFF546E7A);
  static const Color mutedText = Color(0xFF78909C);

  static const Color border = Color(0xFFE0E4DC);
  static const Color divider = Color(0xFFE8ECE4);

  static const Color earth = Color(0xFF795548);
  static const Color earthLight = Color(0xFFEFEBE9);

  static const Color harvest = Color(0xFFFFB300);
  static const Color harvestLight = Color(0xFFFFF3CD);

  static const Color water = Color(0xFF0288D1);
  static const Color waterLight = Color(0xFFE1F5FE);

  static const Color leaf = Color(0xFF43A047);
  static const Color leafLight = Color(0xFFF1F8E9);

  static const Color surface = Colors.white;

  // ============================================================
  // SPACING
  // ============================================================

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // ============================================================
  // PAGE / CARD PADDING
  // ============================================================

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  // ============================================================
  // CARD
  // ============================================================

  static const Color card = Colors.white;

  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusRound = 999;

  // ============================================================
  // TEXT
  // ============================================================

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: secondaryText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: mutedText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: white,
  );

  static const TextStyle buttonDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: text,
  );

  // ============================================================
  // DECORATIONS
  // ============================================================

  static BoxDecoration cardDecoration({
    Color? color,
    double radius = radiusLarge,
  }) {
    return BoxDecoration(
      color: color ?? card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration greenCardDecoration({
    double radius = radiusLarge,
  }) {
    return BoxDecoration(
      color: primaryLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: secondaryLight),
    );
  }

  static BoxDecoration inputDecoration({
    Color? color,
    double radius = radiusMedium,
  }) {
    return BoxDecoration(
      color: color ?? card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
    );
  }

  static RoundedRectangleBorder buttonShape({
    double radius = radiusMedium,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'confirmed':
        return info;
      case 'preparing':
        return primary;
      case 'ready':
        return secondary;
      case 'delivered':
        return success;
      case 'completed':
        return primaryDark;
      case 'cancelled':
      case 'canceled':
        return error;
      case 'active':
        return success;
      case 'inactive':
        return mutedText;
      default:
        return mutedText;
    }
  }

  static Color statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningLight;
      case 'confirmed':
        return infoLight;
      case 'preparing':
        return primaryLight;
      case 'ready':
      case 'delivered':
      case 'active':
        return successLight;
      case 'completed':
        return primaryLight;
      case 'cancelled':
      case 'canceled':
        return errorLight;
      case 'inactive':
        return const Color(0xFFECEFF1);
      default:
        return const Color(0xFFECEFF1);
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'preparing':
        return Icons.inventory_2_outlined;
      case 'ready':
        return Icons.task_alt_rounded;
      case 'delivered':
        return Icons.local_shipping_outlined;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}