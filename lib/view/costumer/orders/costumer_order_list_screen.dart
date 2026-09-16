import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_orders_list_controller.dart';

class OrdersListView extends GetView<OrdersListController> {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.orders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.divider,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'No orders yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Your placed orders will show up here.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: controller.orders.length,
                itemBuilder: (_, i) {
                  final order = controller.orders[i];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      onTap: () {
                        controller.openTracking(order);
                      },

                      title: Text(
                        '#${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        '${order.farmName} • '
                        '${order.itemCount} items',
                      ),

                      trailing: Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
