import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  OrderTrackingController get controller =>
      Get.isRegistered<OrderTrackingController>()
          ? Get.find<OrderTrackingController>()
          : Get.put(OrderTrackingController());

  @override
  Widget build(BuildContext context) {
    final order = controller.order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64),
                const SizedBox(height: 12),
                const Text('We couldn\'t find an order to track.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: Get.back, child: const Text('Go Back')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Track Order #${order.id}'), leading: const BackButton()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(controller.steps.length, (index) => _StepTile(
                  label: controller.steps[index],
                  done: index <= controller.currentStepIndex,
                  isLast: index == controller.steps.length - 1,
                )),
            const SizedBox(height: 16),
            const Text('Delivery Route', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 160,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.map_outlined, size: 40, color: AppColors.primary)),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                title: Text(order.farmerName),
                subtitle: Text('Your Farmer • ${order.farmName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Call ${order.farmerName}',
                      onPressed: () => _showContactMessage(context, 'Call ${order.farmerPhone}'),
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                    ),
                    IconButton(
                      tooltip: 'Message ${order.farmerName}',
                      onPressed: () => _showContactMessage(context, 'Message ${order.farmerPhone}'),
                      icon: const Icon(Icons.message, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.items.isEmpty
                  ? 'No items in this order'
                  : order.items.length > 1
                      ? '${order.items.first.productName} + ${order.items.length - 1} more'
                      : order.items.first.productName,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showContactMessage(context, 'Contact ${order.farmerName} at ${order.farmerPhone}'),
              child: const Text('Contact Farmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.label, required this.done, required this.isLast});

  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: done ? AppColors.primary : AppColors.divider,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: done ? AppColors.primary : AppColors.divider),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                color: done ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
