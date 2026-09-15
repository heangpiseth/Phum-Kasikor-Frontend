import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${order.id}'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(controller.steps.length, (i) {
              final done = i <= controller.currentStepIndex;
              return _StepTile(
                label: controller.steps[i],
                done: done,
                isLast: i == controller.steps.length - 1,
              );
            }),
            const SizedBox(height: 16),
            const Text('Delivery Route', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(Icons.map_outlined, size: 40, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                ),
                title: Text(order.farmerName),
                subtitle: Text('Your Farmer • ${order.farmName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.phone, color: AppColors.primary),
                    SizedBox(width: 12),
                    Icon(Icons.message, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.items.isEmpty
                  ? ''
                  : '${order.items.first.product.name}'
                      '${order.items.length > 1 ? ' + ${order.items.length - 1} more' : ''}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text('Contact Farmer')),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String label;
  final bool done;
  final bool isLast;
  const _StepTile({required this.label, required this.done, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.primary : AppColors.divider,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? AppColors.primary : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
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