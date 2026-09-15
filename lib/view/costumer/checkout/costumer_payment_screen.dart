import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_payment_controller.dart';

class CostumerPaymentScreen extends GetView<PaymentController> {
  const CostumerPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Payment'),
        leading: const BackButton(),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Payment information
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '✓ Direct Farm Payment • No Fees',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _row(
              'Farmer Payee',
              order.farmerName,
            ),

            _row(
              'Farm Shop',
              order.farmName,
            ),

            _row(
              'Payment Reference',
              '#${order.id}',
              valueColor: AppColors.accentOrange,
            ),

            _row(
              'Amount Due',
              '\$${order.total.toStringAsFixed(2)}',
              valueBold: true,
            ),

            const SizedBox(height: 20),

            // QR Code
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 120,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Scan to Pay Directly',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Obx(
                      () => Text(
                        '${controller.formattedTime} '
                        'left to complete payment',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bank transfer
            const Text(
              'Or Bank Transfer Details',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ABA Account: 000 123 456\n'
                'Account Name: Sokha Vann',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Payment actions
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.confirmPaymentCompleted,
                  child: const Text(
                    "I've Completed Payment",
                  ),
                ),
              ),

              const SizedBox(height: 4),

              TextButton(
                onPressed: controller.cancelOrder,
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
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
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color:
                    valueColor ??
                    AppColors.textPrimary,
                fontWeight: valueBold
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: valueBold ? 18 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
