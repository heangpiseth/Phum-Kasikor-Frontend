import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_add_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_crop_deteil_screen.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';
import 'package:phum_kasikors/widgets/farmer/crop_cart.dart';


class FarmerCropsScreen extends StatelessWidget {
  const FarmerCropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return FarmerPage(
      title: 'Crops Monitor',
      action: IconButton(
        tooltip: 'Add crop',
        onPressed: () => Get.to(() => const FarmerAddCropScreen()),
        icon: const Icon(Icons.add),
      ),
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Track every crop from planting to harvest.',
              style: TextStyle(color: Color(0xFF718074)),
            ),
            const SizedBox(height: 18),
            ...farmer.crops.map(
              (crop) => CropCard(
                name: crop.name,
                image: crop.imageUrl,
                status: crop.status,
                onTap: () =>
                    Get.to(() => FarmerCropDetailScreen(cropId: crop.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
