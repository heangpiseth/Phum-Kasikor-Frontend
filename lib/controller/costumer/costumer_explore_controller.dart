import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

class ExploreCategory {
  final String label;
  final IconData icon;
  final String? apiCategoryName;
  const ExploreCategory(this.label, this.icon, this.apiCategoryName);
}

class ExploreController extends GetxController {
  final repository = Get.find<CustomerProductRepository>();

  final RxList<ExploreCategory> categories = <ExploreCategory>[].obs;

  final RxList<ProductModel> popularProducts = <ProductModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _syncProducts();
    _loadCategories();
    ever(repository.products, (_) => _syncProducts());
    ever(repository.isLoading, (_) => _syncProducts());
    ever(repository.errorMessage, (_) => _syncProducts());
    ever(repository.categories, (_) => _loadCategories());
  }

  void _syncProducts() {
    isLoading.value = repository.isLoading.value;
    errorMessage.value = repository.errorMessage.value;
    if (!repository.isLoading.value && repository.errorMessage.value.isEmpty) {
      popularProducts.assignAll(repository.products);
    }
  }

  void _loadCategories() {
    if (repository.categories.isNotEmpty) {
      categories.assignAll(
        repository.categories.map((c) {
          return ExploreCategory(
            c.name,
            _getIconForCategory(c.name),
            c.name.toLowerCase(),
          );
        }).toList(),
      );
    } else {
      // Fallback to default categories if API doesn't return them
      categories.assignAll(_getDefaultCategories());
    }
  }

  List<ExploreCategory> _getDefaultCategories() {
    return const [
      ExploreCategory('Vegetables', Icons.eco, 'vegetables'),
      ExploreCategory('Fruits', Icons.apple, 'fruits'),
      ExploreCategory('Rice & Grains', Icons.rice_bowl, 'rice'),
      ExploreCategory('Herbs & Spices', Icons.local_florist, 'herbs'),
      ExploreCategory('Dairy & Eggs', Icons.egg, 'dairy'),
      ExploreCategory('Processed', Icons.inventory_2, 'processed'),
      ExploreCategory('Organic', Icons.spa, 'organic'),
      ExploreCategory('Specialty', Icons.star, 'specialty'),
    ];
  }

  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('vegetable')) return Icons.eco;
    if (name.contains('fruit')) return Icons.apple;
    if (name.contains('rice') || name.contains('grain')) return Icons.rice_bowl;
    if (name.contains('herb') || name.contains('spice')) {
      return Icons.local_florist;
    }
    if (name.contains('dairy') || name.contains('egg')) return Icons.egg;
    if (name.contains('processed')) return Icons.inventory_2;
    if (name.contains('organic')) return Icons.spa;
    return Icons.star;
  }

  void openCategory(ExploreCategory category) {
    Get.toNamed(
      AppRoutes.costumerSearchFilterscreen,
      arguments: category.apiCategoryName,
    );
  }

  void openSeasonalPick() {
    Get.toNamed(AppRoutes.costumerSearchFilterscreen, arguments: 'fruits');
  }

  void openProduct(ProductModel product) =>
      Get.toNamed(AppRoutes.costumerProductDetailscreen, arguments: product);
}
