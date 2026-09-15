import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';


class FarmerFarmProfile extends StatelessWidget {
  const FarmerFarmProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return FarmerPage(
      title: 'Farm Profile',
      action: IconButton(
        tooltip: 'Edit profile',
        onPressed: () => Get.snackbar(
          'Edit profile',
          'Farm profile editing is ready to connect to your API.',
        ),
        icon: const Icon(Icons.edit_outlined),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.agriculture_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Sokha Organic Farm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const Center(
            child: Text(
              'Chamkarmon, Phnom Penh',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => Row(
              children: [
                _Stat(value: '${farmer.products.length}', label: 'Products'),
                _Stat(value: '${farmer.crops.length}', label: 'Crops'),
                const _Stat(value: '4.8', label: 'Rating'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'About the farm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'We grow fresh, responsibly cultivated produce for our local community.',
            style: TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}
