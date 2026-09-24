import 'package:flutter/material.dart';

import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerBottomNavigationBar extends StatelessWidget {
  const FarmerBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          12,
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. HOME
              _FarmerNavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                onTap: onChanged,
              ),

              // 2. PRODUCTS
              _FarmerNavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Products',
                onTap: onChanged,
              ),

              // 3. ORDERS
              _FarmerNavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'Orders',
                onTap: onChanged,
              ),

              // 4. AI CHAT
              _FarmerNavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome_rounded,
                label: 'AI Chat',
                onTap: onChanged,
              ),

              // 5. PROFILE
              _FarmerNavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                onTap: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerNavItem extends StatelessWidget {
  const _FarmerNavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? FarmerDesign.primaryLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected
                      ? selectedIcon
                      : icon,
                  key: ValueKey<bool>(isSelected),
                  size: 23,
                  color: isSelected
                      ? FarmerDesign.primary
                      : FarmerDesign.secondaryText,
                ),
              ),

              const SizedBox(height: 4),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? FarmerDesign.primary
                      : FarmerDesign.secondaryText,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}