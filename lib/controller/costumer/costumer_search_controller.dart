import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';


// Named SearchFilterController (not SearchController) to avoid clashing
// with Flutter Material's own SearchController class.
class SearchFilterController extends GetxController {
  final _dataService = MockDataService.to;

  final queryText = ''.obs;
  final isOrganicOnly = false.obs;
  final isVegetablesOnly = false.obs;
  final categoryFilter = Rxn<ProductCategory>();
  final priceMax = 50.0.obs;
  final priceMin = 0.0.obs;

  late final RxList<ProductModel> results = <ProductModel>[].obs;

  final searchField = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ProductCategory) {
      categoryFilter.value = arg;
      isVegetablesOnly.value = arg == ProductCategory.vegetables;
    }
    searchField.text = queryText.value;
    runSearch();
  }

  @override
  void onClose() {
    searchField.dispose();
    super.onClose();
  }

  void runSearch() {
    var list = _dataService.search(queryText.value);
    final category = categoryFilter.value;
    if (category != null) {
      list = list.where((p) => p.category == category).toList();
    }
    list = list.where((p) => p.price <= priceMax.value && p.price >= priceMin.value).toList();
    if (isOrganicOnly.value) {
      list = list
          .where((p) => p.method.toLowerCase().contains('organic'))
          .toList();
    }
    results.assignAll(list);
  }

  void clearFilters() {
    isOrganicOnly.value = false;
    isVegetablesOnly.value = false;
    categoryFilter.value = null;
    priceMin.value = 0;
    priceMax.value = 50;
    runSearch();
  }

  void updatePriceRange(double min, double max) {
    priceMin.value = min;
    priceMax.value = max;
    runSearch();
  }

  void setVegetablesOnly(bool enabled) {
    isVegetablesOnly.value = enabled;
    categoryFilter.value = enabled ? ProductCategory.vegetables : null;
    runSearch();
  }

  void openProduct(ProductModel product) =>
      Get.toNamed('/costumer/product-detailscreen', arguments: product);
}
