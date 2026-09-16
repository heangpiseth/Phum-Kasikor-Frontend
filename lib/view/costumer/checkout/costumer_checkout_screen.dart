import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_checkout_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Direct Farm Payment: You pay the farmer directly '
                      'with no middleman escrow or platform fees.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle(
              'Delivery Address',
              trailing: 'Edit',
              onTrailingTap: controller.editAddress,
            ),
            const SizedBox(height: 6),
            Obx(
              () => Text(
                controller.deliveryAddress.value,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Delivery Method'),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _deliveryOption(
                      label: 'Standard',
                      subtitle: '2-3 Days • Free',
                      selected: controller.deliveryMethod.value ==
                          DeliveryMethod.standard,
                      onTap: () => controller
                          .setDeliveryMethod(DeliveryMethod.standard),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _deliveryOption(
                      label: 'Express',
                      subtitle: 'Same Day • \$3.00',
                      selected: controller.deliveryMethod.value ==
                          DeliveryMethod.express,
                      onTap: () => controller
                          .setDeliveryMethod(DeliveryMethod.express),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Obx(
              () => _sectionTitle(
                '${controller.cart.itemCount} Items Selected',
                trailing:
                    '\$${controller.cart.subtotal.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pay Farmer Directly',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              "Direct payment to farm's account",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => RadioGroup<PaymentMethod>(
                groupValue: controller.selectedPayment.value,
                onChanged: (value) {
                  if (value != null) controller.selectPayment(value);
                },
                child: Column(
                  children: PaymentMethod.values.map((method) {
                    return RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      value: method,
                      activeColor: AppColors.primary,
                      title: Text(method.label),
                      subtitle: Text(
                        method.subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add delivery requests or instructions...',
                labelText: 'Order Note (Optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => controller.orderNote.value = value,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.cart.itemCount == 0
                    ? null
                    : controller.placeOrder,
                child: Text(
                  'Place Order — \$${controller.total.toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _deliveryOption({
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}