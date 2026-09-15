import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';

class FarmerCropDetailScreen extends StatelessWidget {
  const FarmerCropDetailScreen({super.key, required this.cropId});
  final String cropId;

  @override
  Widget build(BuildContext context) {
    final crop = Get.find<FarmerController>().crops.firstWhere(
      (item) => item.id == cropId,
    );
    final daysGrowing = DateTime.now()
        .difference(crop.plantedAt)
        .inDays
        .clamp(0, 999);
    return FarmerPage(
      title: 'Crop Details',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 190,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.grass_rounded,
              color: AppColors.primary,
              size: 92,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            crop.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            crop.status,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _Metric(
            label: 'Days growing',
            value: '$daysGrowing days',
            icon: Icons.calendar_today_outlined,
          ),
          _Metric(
            label: 'Planted',
            value: _date(crop.plantedAt),
            icon: Icons.spa_outlined,
          ),
          _Metric(
            label: 'Expected harvest',
            value: _date(crop.expectedHarvestAt),
            icon: Icons.agriculture_outlined,
          ),
          const SizedBox(height: 16),
          const Text(
            'Crop notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep monitoring soil moisture and remove weeds as needed.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _date(DateTime? date) =>
      date == null ? 'Not set' : '${date.day}/${date.month}/${date.year}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: AppColors.primaryLight,
      child: Icon(icon, color: AppColors.primary),
    ),
    title: Text(
      label,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
