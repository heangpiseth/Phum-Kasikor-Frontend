import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_order_detil_screen.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';
import 'package:phum_kasikors/widgets/farmer/order_cart.dart';


class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return FarmerPage(
      title: 'Orders',
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Manage new, preparing, and completed orders.',
              style: TextStyle(color: Color(0xFF718074)),
            ),
            const SizedBox(height: 16),
            ...farmer.orders.map(
              (order) => FarmerOrderCard(
                order: order,
                onTap: () =>
                    Get.to(() => FarmerOrderDetailScreen(orderId: order.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
