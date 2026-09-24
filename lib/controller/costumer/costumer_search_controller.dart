import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

class SearchFilterController extends GetxController {
  final repository = Get.find<CustomerProductRepository>();

  final queryText = ''.obs;
  final isOrganicOnly = false.obs;
  final isVegetablesOnly = false.obs;
  final categoryFilter = Rxn<String>();
  final priceMax = 50.0.obs;
  final priceMin = 0.0.obs;

  final RxList<ProductModel> results = <ProductModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final searchField = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is String) {
      categoryFilter.value = arg;
      isVegetablesOnly.value = arg == 'vegetables';
    }
    searchField.text = queryText.value;

    ever(repository.products, (_) => _maybeRunSearch());
    ever(repository.isLoading, (_) => _maybeRunSearch());
    ever(repository.errorMessage, (_) => _maybeRunSearch());

    _maybeRunSearch();
  }

  void _maybeRunSearch() {
    if (repository.isLoading.value ||
        repository.errorMessage.value.isNotEmpty) {
      isLoading.value = repository.isLoading.value;
      errorMessage.value = repository.errorMessage.value;
      return;
    }
    isLoading.value = false;
    errorMessage.value = '';
    runSearch();
  }

  @override
  void onClose() {
    searchField.dispose();
    super.onClose();
  }

  Future<void> runSearch() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final query = queryText.value;
      var list = query.isEmpty
          ? List<ProductModel>.from(repository.products)
          : await repository.searchProducts(query);

      final category = categoryFilter.value;
      if (category != null) {
        list = list.where((p) {
          final catName = p.category?.name.toLowerCase() ?? '';
          return catName == category.toLowerCase();
        }).toList();
      }

      list = list
          .where((p) => p.price <= priceMax.value && p.price >= priceMin.value)
          .toList();

      if (isOrganicOnly.value) {
        list = list
            .where(
              (p) => (p.farm?.farmingMethod ?? '').toLowerCase().contains(
                'organic',
              ),
            )
            .toList();
      }

      results.assignAll(list);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
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
    categoryFilter.value = enabled ? 'vegetables' : null;
    runSearch();
  }

  void openProduct(ProductModel product) =>
      Get.toNamed(AppRoutes.costumerProductDetailscreen, arguments: product);
}
