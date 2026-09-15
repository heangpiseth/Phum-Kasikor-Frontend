import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args is! OrderModel) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'We couldn\'t find your order details.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.main);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final order = args;

    final estimatedDelivery =
        order.date.add(const Duration(days: 3));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Success icon
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Payment Reference #${order.id}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _row(
                                'Date',
                                '${order.date.month}/${order.date.day}/${order.date.year}',
                              ),
                              _row(
                                'Payment Method',
                                order.paymentMethod.label,
                              ),
                              _row(
                                'Paid To',
                                order.farmName,
                              ),

                              const Divider(),

                              _row(
                                'Subtotal',
                                '\$${order.subtotal.toStringAsFixed(2)}',
                              ),

                              _row(
                                'Delivery',
                                '\$${order.deliveryFee.toStringAsFixed(2)}',
                              ),

                              const Divider(),

                              _row(
                                'Total Amount',
                                '\$${order.total.toStringAsFixed(2)}',
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.local_shipping_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text(
                            'Estimated Delivery',
                          ),
                          subtitle: Text(
                            '${estimatedDelivery.month}/'
                            '${estimatedDelivery.day}/'
                            '${estimatedDelivery.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamed(
                      AppRoutes.costumerOrderTrackingscreen,
                      arguments: order,
                    );
                  },
                  child: const Text('Track Order'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.main);
                  },
                  child: const Text('Continue Shopping'),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  // TODO: Download receipt
                },
                child: const Text('Download Receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}