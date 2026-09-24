import 'dart:async';

import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';
import 'package:phum_kasikors/core/service/customer/customer_service.dart';

class CustomerProductRepository extends GetxService {
  CustomerProductRepository({CustomerService? service})
    : _service = service ?? CustomerService();

  final CustomerService _service;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<FarmModel> farms = <FarmModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _refreshTimer;
  Future<void>? _loadFuture;
  int _loadGeneration = 0;
  final Map<int, List<ReviewModel>> _reviewCache = <int, List<ReviewModel>>{};

  @override
  void onInit() {
    super.onInit();
    load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isLoading.value) {
        load(silent: true);
      }
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> load({bool silent = false}) {
    final activeLoad = _loadFuture;
    if (activeLoad != null && !silent) {
      return activeLoad;
    }

    final pendingLoad = _performLoad(silent: silent);
    _loadFuture = pendingLoad;
    pendingLoad.whenComplete(() {
      if (identical(_loadFuture, pendingLoad)) {
        _loadFuture = null;
      }
    });
    return pendingLoad;
  }

  Future<void> refresh() => load();

  Future<void> _performLoad({required bool silent}) async {
    final generation = ++_loadGeneration;
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    List<ProductModel> loadedProducts = const <ProductModel>[];
    List<CategoryModel>? loadedCategories;
    Object? productError;

    try {
      loadedProducts = await _fetchAllProducts();
    } catch (error) {
      productError = error;
    }

    try {
      loadedCategories = await _fetchCategories();
    } catch (_) {}

    if (generation != _loadGeneration) {
      return;
    }

    if (productError == null) {
      products.assignAll(loadedProducts);
      farms.assignAll(_farmsFromProducts(loadedProducts));
      if (loadedCategories != null) {
        categories.assignAll(loadedCategories);
      }
      errorMessage.value = '';
    } else {
      errorMessage.value = _errorMessage(productError);
    }

    if (!silent) {
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> _fetchAllProducts() async {
    var page = 1;
    final allProducts = <ProductModel>[];

    while (true) {
      final response = await _service.getCustomerProducts(page: page);
      allProducts.addAll(response.data);

      if (response.nextPageUrl == null ||
          response.data.isEmpty ||
          page >= response.lastPage) {
        break;
      }
      page++;
    }

    return allProducts;
  }

  Future<List<CategoryModel>?> _fetchCategories() async {
    final response = await _service.getCategories();
    return response.categories;
  }

  List<FarmModel> _farmsFromProducts(List<ProductModel> allProducts) {
    final uniqueFarms = <int, FarmModel>{};
    for (final product in allProducts) {
      final farm = product.farm;
      if (farm != null) {
        uniqueFarms[product.farmId] = farm;
      }
    }
    return uniqueFarms.values.toList();
  }

  Future<FarmDetailResponse?> getFarmDetail(int farmId) async {
    if (products.isEmpty && farms.isEmpty) {
      await load();
    }

    var farm = farmById(farmId.toString());
    var detailProducts = productsByFarm(farmId.toString());

    if (farm == null || detailProducts.isEmpty) {
      final response = await _service.getCustomerProducts(farmId: farmId);
      detailProducts = response.data;
      farm ??= _farmFromProducts(detailProducts);
      if (farm == null) {
        return null;
      }
    }

    final detailReviews = await _reviewsForProducts(detailProducts);
    return FarmDetailResponse(
      farm: farm,
      products: detailProducts,
      reviews: detailReviews,
    );
  }

  FarmModel? _farmFromProducts(List<ProductModel> productsForFarm) {
    for (final product in productsForFarm) {
      if (product.farm != null) {
        return product.farm;
      }
    }
    return null;
  }

  Future<List<ReviewModel>> getProductReviews(int productId) async {
    final cachedReviews = _reviewCache[productId];
    if (cachedReviews != null) {
      return cachedReviews;
    }

    try {
      final reviews = await _service.getProductReviews(productId);
      _reviewCache[productId] = reviews;
      return reviews;
    } catch (_) {
      _reviewCache[productId] = const <ReviewModel>[];
      return const <ReviewModel>[];
    }
  }

  Future<List<ReviewModel>> _reviewsForProducts(
    List<ProductModel> productsForFarm,
  ) async {
    final productIds = productsForFarm.map((product) => product.id).toSet();
    final missingIds = productIds.where((id) => !_reviewCache.containsKey(id));

    await Future.wait(
      missingIds.map((productId) async {
        await getProductReviews(productId);
      }),
    );

    return productIds
        .map((productId) => _reviewCache[productId] ?? const <ReviewModel>[])
        .expand((reviews) => reviews)
        .toList();
  }

  List<ProductModel> productsByFarm(String farmId) {
    final parsedFarmId = int.tryParse(farmId);
    if (parsedFarmId == null) {
      return const <ProductModel>[];
    }
    return products.where((product) => product.farmId == parsedFarmId).toList();
  }

  FarmModel? farmById(String farmId) {
    final parsedFarmId = int.tryParse(farmId);
    if (parsedFarmId == null) {
      return null;
    }
    return farms.firstWhereOrNull((farm) => farm.id == parsedFarmId);
  }

  List<ProductModel> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<ProductModel>.from(products);
    }

    return products.where((product) {
      final farmName = product.farm?.farmName.toLowerCase() ?? '';
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery) ||
          farmName.contains(normalizedQuery);
    }).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _service.getCustomerProducts(search: query);
    return response.data;
  }

  String _errorMessage(Object error) {
    return error.toString();
  }
}

class FarmDetailResponse {
  final FarmModel farm;
  final List<ProductModel> products;
  final List<ReviewModel> reviews;

  FarmDetailResponse({
    required this.farm,
    required this.products,
    required this.reviews,
  });
}
