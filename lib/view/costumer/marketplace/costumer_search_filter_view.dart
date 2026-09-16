import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_search_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

class SearchView extends GetView<SearchFilterController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: controller.searchField,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Organic vegetables',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
            border: InputBorder.none,
          ),
          onSubmitted: (v) {
            controller.queryText.value = v;
            controller.runSearch();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  children: [
                    if (controller.isOrganicOnly.value)
                      _filterTag('Organic', () {
                        controller.isOrganicOnly.value = false;
                        controller.runSearch();
                      }),
                    if (controller.isVegetablesOnly.value)
                      _filterTag('Vegetables', () {
                        controller.setVegetablesOnly(false);
                      }),
                    _filterTag(
                      'Under \$${controller.priceMax.value.toInt()}',
                      () {
                        controller.priceMax.value = 50;
                        controller.runSearch();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      '${controller.results.length} products found',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 18),
                        SizedBox(width: 2),
                        Text('Filter Options'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.results.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.results.length,
                  itemBuilder: (_, i) {
                    final ProductModel p = controller.results[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        onTap: () => controller.openProduct(p),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 56,
                              height: 56,
                              color: AppColors.divider,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${p.priceLabel} • ${p.farmName}'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                        onPressed: () => cart.addProduct(p , quantity: 1),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTag(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
      backgroundColor: AppColors.primaryLight,
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Price Range: \$${controller.priceMin.value.toInt()} - '
                '\$${controller.priceMax.value.toInt()}',
              ),
              RangeSlider(
                values: RangeValues(
                  controller.priceMin.value,
                  controller.priceMax.value,
                ),
                min: 0,
                max: 50,
                activeColor: AppColors.primary,
                onChanged: (v) => controller.updatePriceRange(v.start, v.end),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Organic only'),
                value: controller.isOrganicOnly.value,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : null,
                ),
                onChanged: (v) {
                  controller.isOrganicOnly.value = v;
                  controller.runSearch();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vegetables only'),
                value: controller.isVegetablesOnly.value,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : null,
                ),
                onChanged: (v) {
                  controller.setVegetablesOnly(v);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
