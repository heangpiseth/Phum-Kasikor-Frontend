import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_add_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_crop_screen.dart';
import 'package:phum_kasikors/widgets/ai_assistant/ai_assistant_compact_card.dart';


class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Good morning, ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm overview',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your crops are growing well',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const AiAssistantCompactCard(isFarmer: true),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active crops',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const FarmerCropsScreen()),
                  child: const Text('View all'),
                ),
              ],
            ),
            Obx(
              () => Text(
                '${farmer.crops.length} crops currently monitored',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const FarmerAddCropScreen()),
                icon: const Icon(Icons.add),
                label: const Text('Add crop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
