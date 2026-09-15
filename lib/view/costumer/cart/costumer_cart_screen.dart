import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('My Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Obx(() => Text('${controller.itemCount} items',
                    style: const TextStyle(color: AppColors.textSecondary))),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: AppColors.textDark),
                      SizedBox(height: 12),
                      Text('Your cart is empty',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.items.length,
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.textDark.withOpacity(0.1),
                                child: const Icon(Icons.image_not_supported_outlined,
                                    size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('\$${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () => controller.decrement(item.product.id),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => controller.increment(item.product.id),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: AppColors.error),
                                onPressed: () => controller.removeItem(item.product.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() => controller.items.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.textDark)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter promo code',
                                isDense: true,
                              ),
                              // Keep controller.promoCode in sync as the user
                              // types, so the Apply button (which reads
                              // controller.promoCode.value) isn't stale.
                              onChanged: (v) => controller.promoCode.value = v,
                              onSubmitted: controller.applyPromoCode,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                controller.applyPromoCode(controller.promoCode.value),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _summaryRow('Subtotal', controller.subtotal),
                      _summaryRow('Delivery Fee', controller.deliveryFee.value),
                      const Divider(),
                      _summaryRow('Total Amount', controller.total, isTotal: true),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.goToCheckout,
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    final style = isTotal
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : const TextStyle(color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}