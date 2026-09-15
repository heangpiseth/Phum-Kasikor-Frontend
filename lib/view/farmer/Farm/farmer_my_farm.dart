import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_product_screen.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';
import 'package:phum_kasikors/widgets/farmer/earing_cart.dart';
import 'package:phum_kasikors/widgets/farmer/farm_stat_cart.dart';


class FarmerMyFarmScreen extends StatelessWidget {
  const FarmerMyFarmScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return FarmerPage(
      title: 'My Farm',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            ' Organic Farm',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            ', Phnom Penh',
            style: TextStyle(color: Color(0xFF718074)),
          ),
          const SizedBox(height: 20),
          const EarningCard(amount: '\$1,240.00', label: 'This month earnings'),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                FarmStatCard(
                  label: 'Crops',
                  value: '${farmer.crops.length}',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(width: 10),
                FarmStatCard(
                  label: 'Products',
                  value: '${farmer.products.length}',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 10),
                const FarmStatCard(
                  label: 'Rating',
                  value: '4.8',
                  icon: Icons.star_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: const Text('Crops monitor'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const FarmerCropsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Product catalog'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const FarmerProductsScreen()),
          ),
        ],
      ),
    );
  }
}
