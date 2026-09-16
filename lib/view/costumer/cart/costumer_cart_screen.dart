import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';

class CustomerCartScreen extends GetView<CartController> {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Obx(() {
        if (controller.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text('Your cart is empty'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = controller.items[index];
                  final product = item.product;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 72,
                                height: 72,
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(product.priceLocal, style: const TextStyle(color: AppColors.primary)),
                                Row(
                                  children: [
                                    IconButton(onPressed: () => controller.decreaseQuantity(product.id), icon: const Icon(Icons.remove_circle_outline)),
                                    Text('${item.quantity}'),
                                    IconButton(onPressed: () => controller.increaseQuantity(product.id), icon: const Icon(Icons.add_circle_outline)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => controller.removeProduct(product.id), icon: const Icon(Icons.delete_outline)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                child: Row(
                  children: [
                    Expanded(child: Text('Total: \$${controller.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ElevatedButton(onPressed: () => Get.toNamed(AppRoutes.costumerCheckoutscreen), child: const Text('Checkout')),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
