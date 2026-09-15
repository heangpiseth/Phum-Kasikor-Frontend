import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/view/farmer/Farm/farmer_farm_profile.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF587585)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF91AAB5)),
            ],
          ),
        ),
      ),
    ),
  );
}

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => FarmerPage(
    title: 'Profile',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Sokha Organic Farm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 24),
        _ProfileMenuTile(
          icon: Icons.agriculture_outlined,
          label: 'Farm profile',
          onTap: () => Get.to(() => const FarmerFarmProfile()),
        ),
        _ProfileMenuTile(
          icon: Icons.settings_outlined,
          label: 'Account settings',
          onTap: () => Get.snackbar('Account settings', 'Coming soon.'),
        ),
      ],
    ),
  );
}
