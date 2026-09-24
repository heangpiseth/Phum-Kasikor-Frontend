import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

class HomeController extends GetxController {
  final repository = Get.find<CustomerProductRepository>();

  final TextEditingController searchController = TextEditingController();

  final RxString searchQuery = ''.obs;

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  final RxString selectedFilter = 'All'.obs;

  final RxList<String> categories = <String>[
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Herbs',
  ].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<FarmModel> featuredFarms = <FarmModel>[].obs;
  final RxList<ProductModel> freshToday = <ProductModel>[].obs;
  final RxList<FarmModel> nearYou = <FarmModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    user.value = UserModel(
      name: 'Channa',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      location: 'Phnom Penh, Cambodia',
      cartCount: 0,
      hasNotification: false,
    );

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    ever(repository.products, (_) => _syncData());
    ever(repository.farms, (_) => _syncData());
    ever(repository.isLoading, (_) => _syncData());
    ever(repository.errorMessage, (_) => _syncData());

    _syncData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _syncData() {
    isLoading.value = repository.isLoading.value;
    errorMessage.value = repository.errorMessage.value;

    if (!repository.isLoading.value && repository.errorMessage.value.isEmpty) {
      freshToday.assignAll(repository.products);
      featuredFarms.assignAll(repository.farms.take(4));
      nearYou.assignAll(repository.farms.reversed.take(4));
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void openFilter() {
    Get.toNamed('/costumer/search-filterscreen');
  }

  void openFarm(FarmModel farm) {
    Get.toNamed(
      AppRoutes.costumerFarmDetailscreen,
      arguments: farm.id.toString(),
    );
  }

  void openNearbyFarm(FarmModel farm) {
    Get.toNamed(
      AppRoutes.costumerFarmDetailscreen,
      arguments: farm.id.toString(),
    );
  }

  void openProduct(ProductModel product) {
  Get.toNamed(
    AppRoutes.costumerProductDetailscreen,
    arguments: product,
  );
}

  void goToSearch() {
    Get.toNamed('/costumer/search-filterscreen');
  }

  Future<void> refreshHome() async {
    await repository.refresh();
  }
}

class UserModel {
  final String name;
  final String avatarUrl;
  final String location;
  final int cartCount;
  final bool hasNotification;

  UserModel({
    required this.name,
    required this.avatarUrl,
    required this.location,
    required this.cartCount,
    required this.hasNotification,
  });
}
