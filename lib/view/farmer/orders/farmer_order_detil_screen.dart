import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';


class FarmerOrderDetailScreen extends StatelessWidget {
  const FarmerOrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final farmer = Get.find<FarmerController>();
    return Obx(() {
      final order = farmer.orders.firstWhere((item) => item.id == orderId);
      return FarmerPage(
        title: 'Order ${order.id}',
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Row(label: 'Customer', value: order.customer),
            _Row(label: 'Items', value: '${order.itemCount} item(s)'),
            _Row(label: 'Total', value: '\$${order.total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Order status',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: order.status == 'Completed'
                  ? null
                  : () => farmer.advanceOrder(order),
              child: Text(
                order.status == 'Completed'
                    ? 'Order completed'
                    : 'Move to next stage',
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
