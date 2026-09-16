import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
// looked like it returns a different type than farmer/product_model.dart's
// ProductModel (there was a suspicious `as` cast in the original code).
// If your customer-facing product model lives elsewhere (e.g.
// costumer_product_model.dart, matching FarmProductsController), import that
// one instead.
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';

class ExploreCategory {
  final String label;
  final IconData icon;
  final ProductCategory? category;
  const ExploreCategory(this.label, this.icon, this.category);
}

class ExploreController extends GetxController {
  final _dataService = MockDataService.to;

  final categories = const [
    ExploreCategory('Vegetables', Icons.eco, ProductCategory.vegetables),
    ExploreCategory('Fruits', Icons.apple, ProductCategory.fruits),
    ExploreCategory('Rice & Grains', Icons.rice_bowl, ProductCategory.rice),
    ExploreCategory(
      'Herbs & Spices',
      Icons.local_florist,
      ProductCategory.herbs,
    ),
    // ProductCategory enum shown earlier; change back to `dairyEggs` if
    // costumer_product_controller.dart actually defines it that way.
    ExploreCategory('Dairy & Eggs', Icons.egg, ProductCategory.dairy),
    ExploreCategory(
      'Processed',
      Icons.inventory_2,
      ProductCategory.processed,
    ),
    ExploreCategory('Organic', Icons.spa, ProductCategory.organic),
    ExploreCategory('Specialty', Icons.star, ProductCategory.specialty),
  ];

  late final RxList<ProductModel> popularProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // ProductModel — an `as` cast here will throw at runtime if the real
    // element type doesn't actually match.
    popularProducts.assignAll(_dataService.popularProducts);
  }

  void openCategory(ExploreCategory category) {
    Get.toNamed(AppRoutes.costumerSearchFilterscreen, arguments: category.category);
  }

  void openSeasonalPick() {
    Get.toNamed(
      AppRoutes.costumerSearchFilterscreen,
      arguments: ProductCategory.fruits,
    );
  }

  void openProduct(ProductModel product) =>
      Get.toNamed(AppRoutes.costumerProductDetailscreen, arguments: product);
}
