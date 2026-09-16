import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_product_detail_controller.dart';

class CostumerProductDetailView extends GetView<ProductDetailController> {
  const CostumerProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(product.farmName, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(product.priceLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(product.description),
          ],
          const SizedBox(height: 24),
          Obx(() => Row(
            children: [
              IconButton(onPressed: controller.decrement, icon: const Icon(Icons.remove_circle_outline)),
              Text('${controller.quantity.value}', style: const TextStyle(fontSize: 18)),
              IconButton(onPressed: controller.increment, icon: const Icon(Icons.add_circle_outline)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: controller.addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to cart'),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
