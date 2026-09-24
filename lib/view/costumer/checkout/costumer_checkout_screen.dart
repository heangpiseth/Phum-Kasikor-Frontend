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

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ======================================================
            // DIRECT PAYMENT INFO
            // ======================================================

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Direct Farm Payment: You pay the farmer directly with no middleman escrow or platform fees.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // DELIVERY ADDRESS
            // ======================================================

            _sectionTitle(
              'Delivery Address',
              trailing: 'Edit',
              onTrailingTap: controller.editAddress,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.deliveryAddress.value,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // DELIVERY METHOD
            // ======================================================

            _sectionTitle('Delivery Method'),

            const SizedBox(height: 10),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _deliveryOption(
                      icon: Icons.local_shipping_outlined,
                      label: 'Standard',
                      subtitle: '2–3 Days • Free',
                      selected:
                          controller.deliveryMethod.value ==
                              DeliveryMethod.standard,
                      onTap: () {
                        controller.setDeliveryMethod(
                          DeliveryMethod.standard,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _deliveryOption(
                      icon: Icons.bolt_rounded,
                      label: 'Express',
                      subtitle: 'Same Day • \$3.00',
                      selected:
                          controller.deliveryMethod.value ==
                              DeliveryMethod.express,
                      onTap: () {
                        controller.setDeliveryMethod(
                          DeliveryMethod.express,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // ORDER SUMMARY
            // ======================================================

            _sectionTitle(
              'Order Summary',
              trailing:
                  '${controller.cart.itemCount} item${controller.cart.itemCount == 1 ? '' : 's'}',
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: Obx(
                () => Column(
                  children: [
                    _summaryRow(
                      'Items',
                      '\$${controller.cart.subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _summaryRow(
                      'Delivery',
                      controller.deliveryFee == 0
                          ? 'Free'
                          : '\$${controller.deliveryFee.toStringAsFixed(2)}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _summaryRow(
                      'Total',
                      '\$${controller.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // PAYMENT METHOD
            // ======================================================

            const Text(
              'Pay Farmer Directly',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Choose how you will pay the farmer for this order.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 10),

            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: RadioGroup<PaymentMethod>(
                  groupValue: controller.selectedPayment.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectPayment(value);
                    }
                  },
                  child: Column(
                    children: PaymentMethod.values.map(
                      (method) {
                        return RadioListTile<PaymentMethod>(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          value: method,
                          activeColor: AppColors.primary,
                          title: Text(
                            method.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            method.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // ORDER NOTE
            // ======================================================

            const Text(
              'Order Note',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              maxLines: 3,
              onChanged: (value) {
                controller.orderNote.value = value;
              },
              decoration: InputDecoration(
                hintText:
                    'Add delivery requests or instructions...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ==========================================================
      // PLACE ORDER
      // ==========================================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Obx(
            () {
              final isEmpty = controller.cart.itemCount == 0;
              final isLoading = controller.isPlacingOrder.value;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      isEmpty || isLoading
                          ? null
                          : controller.placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.35),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Place Order — \$${controller.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

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
              fontWeight: FontWeight.w700,
              fontSize: 15,
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

  // ============================================================
  // DELIVERY OPTION
  // ============================================================

  Widget _deliveryOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected
                      ? AppColors.primary
                      : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color:
                        selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    size: 21,
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 19,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
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

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
                  isTotal
                      ? FontWeight.w700
                      : FontWeight.w500,
              color:
                  isTotal
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight:
                isTotal
                    ? FontWeight.w800
                    : FontWeight.w600,
            color:
                isTotal
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}