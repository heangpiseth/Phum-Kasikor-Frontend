import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_home_model.dart';

class HomeController extends GetxController {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
      TextEditingController();

  final RxString searchQuery = ''.obs;

  // ============================================================
  // USER
  // ============================================================

  final Rx<UserModel> user = UserModel(
    name: 'Channa',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    location: 'Phnom Penh, Cambodia',
    cartCount: 2,
    hasNotification: true,
  ).obs;

  // ============================================================
  // FILTER
  // ============================================================

  final RxString selectedFilter = 'All'.obs;

  final RxList<String> categories = <String>[
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Herbs',
  ].obs;

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool isLoading = false.obs;

  // ============================================================
  // DATA
  // ============================================================

  final RxList<FarmModel> featuredFarms =
      <FarmModel>[].obs;

  final RxList<ProductModel> freshToday =
      <ProductModel>[].obs;

  final RxList<NearbyFarmModel> nearYou =
      <NearbyFarmModel>[].obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    fetchHomeData();
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ============================================================
  // FETCH DATA
  // ============================================================

  Future<void> fetchHomeData() async {
    isLoading.value = true;

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      // ----------------------------------------------------------
      // FEATURED FARMS
      // ----------------------------------------------------------

      featuredFarms.assignAll([
        FarmModel(
          id: 'farm_sokha',
          name: "Sokha's Organic Farm",
          imageUrl:
              'https://images.unsplash.com/photo-1500937386664-56d1dfef3854',
          rating: 4.8,
          distanceKm: 2.3,
        ),
        FarmModel(
          id: 'farm_battambang',
          name: 'Battambang Sweet Orchard',
          imageUrl:
              'https://images.unsplash.com/photo-1464226184884-fa280b87c399',
          rating: 4.9,
          distanceKm: 5.1,
        ),
      ]);

      // ----------------------------------------------------------
      // FRESH PRODUCTS
      // ----------------------------------------------------------

      freshToday.assignAll([
        ProductModel(
          id: 'p1',
          name: 'Organic Morning Glory',
          imageUrl:
              'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
          price: 1.00,
          unit: 'bunch',
          priceLocal: '4,000៛',
          farmName: "Sokha's Organic Farm",
          rating: 4.8,
        ),
        ProductModel(
          id: 'p2',
          name: 'Kampot Black Pepper',
          imageUrl:
              'https://images.unsplash.com/photo-1599909533730-f9d6f2f5b1e0',
          price: 8.50,
          unit: 'jar',
          priceLocal: '34,000៛',
          farmName: 'Kampot Heritage',
          rating: 4.9,
        ),
        ProductModel(
          id: 'p3',
          name: 'Fresh Tomatoes',
          imageUrl:
              'https://images.unsplash.com/photo-1546094096-0df4bcaaa337',
          price: 2.50,
          unit: 'kg',
          priceLocal: '10,000៛',
          farmName: "Sokha's Organic Farm",
          rating: 4.7,
        ),
        ProductModel(
          id: 'p4',
          name: 'Fresh Carrots',
          imageUrl:
              'https://images.unsplash.com/photo-1445282768818-728615cc910a',
          price: 2.00,
          unit: 'kg',
          priceLocal: '8,000៛',
          farmName: 'Green Farm',
          rating: 4.6,
        ),
      ]);

      // ----------------------------------------------------------
      // NEAR YOU
      // ----------------------------------------------------------

      nearYou.assignAll([
        NearbyFarmModel(
          id: 'farm_prekleap',
          name: 'Prek Leap Eco Farm',
          imageUrl:
              'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
          distanceKm: 1.5,
          area: 'Kandal Border',
          liveProducts: 18,
          rating: 4.7,
        ),
        NearbyFarmModel(
          id: 'farm_battambang',
          name: 'Green Valley Farm',
          imageUrl:
              'https://images.unsplash.com/photo-1492496913980-501348b61469',
          distanceKm: 3.2,
          area: 'Phnom Penh',
          liveProducts: 25,
          rating: 4.8,
        ),
      ]);
    } catch (e) {
      debugPrint('Home data error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void onSearchSubmitted(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void openFilter() {
    Get.toNamed('/costumer/search-filterscreen');
  }

  void openFarm(FarmModel farm) {
    Get.toNamed(AppRoutes.costumerFarmDetailscreen, arguments: farm.id);
  }

  void openNearbyFarm(NearbyFarmModel farm) {
    Get.toNamed(AppRoutes.costumerFarmDetailscreen, arguments: farm.id);
  }

  void openProduct(ProductModel product) {
    Get.snackbar(
      product.name,
      '${product.priceLocal} / ${product.unit}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToSearch() {
    Get.toNamed('/costumer/search-filterscreen');
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshHome() async {
    await fetchHomeData();
  }
}
