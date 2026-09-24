import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';

class FarmerProductController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================

  final products = <ProductModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingImage = false.obs;

  final errorMessage = ''.obs;

  final farmId = RxnString();

  // ============================================================
  // FARM ID
  // ============================================================

  Future<String?> resolveFarmId(
    String? suppliedFarmId,
  ) async {
    final supplied = suppliedFarmId?.trim();

    if (supplied != null &&
        supplied.isNotEmpty &&
        supplied != 'null') {
      farmId.value = supplied;
      return supplied;
    }

    final existing = farmId.value?.trim();

    if (existing != null &&
        existing.isNotEmpty &&
        existing != 'null') {
      return existing;
    }

    try {
      debugPrint(
        'PRODUCT CONTROLLER: Resolving farmer farm...',
      );

      final response = await ApiClient.get(
        'farmer/farms',
      );

      debugPrint(
        'FARM RESPONSE: $response',
      );

      final farm = _extractFirstFarm(response);

      if (farm == null) {
        errorMessage.value =
            'No farm was found for this farmer.';
        return null;
      }

      final id = _readString(farm['id']);

      if (id == null || id.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return null;
      }

      farmId.value = id;

      debugPrint(
        'PRODUCT CONTROLLER: Resolved farm ID = $id',
      );

      return id;
    } catch (e) {
      debugPrint(
        'RESOLVE FARM ID ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return null;
    }
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadProducts([
    String? suppliedFarmId,
  ]) async {
    final resolvedFarmId =
        await resolveFarmId(suppliedFarmId);

    if (resolvedFarmId == null ||
        resolvedFarmId.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint(
        '========================================',
      );
      debugPrint('LOAD FARMER PRODUCTS');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.get(
        'farmer/farms/$resolvedFarmId/products',
      );

      debugPrint(
        'PRODUCT RESPONSE: $response',
      );

      final list = _extractList(response);

      final parsedProducts = <ProductModel>[];

      for (final item in list) {
        if (item is Map) {
          try {
            parsedProducts.add(
              ProductModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (e) {
            debugPrint(
              'PRODUCT PARSE ERROR: $e',
            );
            debugPrint(
              'BAD PRODUCT DATA: $item',
            );
          }
        }
      }

      products.assignAll(parsedProducts);

      farmId.value = resolvedFarmId;

      debugPrint(
        'PRODUCT COUNT: ${products.length}',
      );
    } catch (e) {
      debugPrint(
        'LOAD PRODUCTS ERROR: $e',
      );

      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH PRODUCTS
  // ============================================================

  Future<void> refreshProducts([
    String? suppliedFarmId,
  ]) async {
    await loadProducts(suppliedFarmId);
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  ProductModel? getProductById(
    String productId,
  ) {
    final id = productId.trim();

    if (id.isEmpty) {
      return null;
    }

    try {
      return products.firstWhere(
        (product) => product.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FETCH SINGLE PRODUCT
  // ============================================================

  Future<ProductModel?> fetchProduct({
    required String farmId,
    required String productId,
  }) async {
    try {
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return null;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value = 'Product ID is missing.';
        return null;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('FETCH SINGLE PRODUCT');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.get(
        'farmer/farms/$resolvedFarmId/products/$resolvedProductId',
      );

      debugPrint(
        'SINGLE PRODUCT RESPONSE: $response',
      );

      final productJson = _extractProduct(response);

      if (productJson == null) {
        errorMessage.value =
            'Product data was not returned.';
        return null;
      }

      final product = ProductModel.fromJson(
        productJson,
      );

      final existingIndex = products.indexWhere(
        (item) => item.id == product.id,
      );

      if (existingIndex >= 0) {
        products[existingIndex] = product;
        products.refresh();
      } else {
        products.add(product);
      }

      return product;
    } catch (e) {
      debugPrint(
        'FETCH PRODUCT ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return null;
    }
  }

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

  Future<ProductModel?> createProduct({
    required String farmId,
    required String categoryId,
    required String name,
    required double price,
    required String unit,
    required double quantityAvailable,
    String? description,
    DateTime? harvestDate,
    String? farmingMethod,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return null;
      }

      final category = int.tryParse(
        categoryId.trim(),
      );

      if (category == null) {
        errorMessage.value =
            'Invalid product category.';
        return null;
      }

      if (name.trim().isEmpty) {
        errorMessage.value =
            'Product name is required.';
        return null;
      }

      if (price <= 0) {
        errorMessage.value =
            'Price must be greater than 0.';
        return null;
      }

      if (unit.trim().isEmpty) {
        errorMessage.value = 'Unit is required.';
        return null;
      }

      if (quantityAvailable < 0) {
        errorMessage.value =
            'Quantity cannot be negative.';
        return null;
      }

      final body = <String, dynamic>{
        'category_id': category,
        'name': name.trim(),
        'price': price,
        'unit': unit.trim(),
        'quantity_available': quantityAvailable,
      };

      if (description != null &&
          description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }

      if (harvestDate != null) {
        body['harvest_date'] =
            _formatApiDate(harvestDate);
      }

      if (farmingMethod != null &&
          farmingMethod.trim().isNotEmpty) {
        body['farming_method'] =
            farmingMethod.trim();
      }

      debugPrint(
        '========================================',
      );
      debugPrint('CREATE PRODUCT');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('CATEGORY: $category');
      debugPrint('NAME: ${name.trim()}');
      debugPrint('PRICE: $price');
      debugPrint('QUANTITY: $quantityAvailable');
      debugPrint('UNIT: ${unit.trim()}');
      debugPrint('BODY: $body');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.post(
        'farmer/farms/$resolvedFarmId/products',
        body,
      );

      debugPrint(
        'CREATE PRODUCT RESPONSE: $response',
      );

      final productJson =
          _extractProduct(response);

      if (productJson == null) {
        errorMessage.value =
            'Product was created, but the server did not return product data.';

        await loadProducts(resolvedFarmId);

        return null;
      }

      final product = ProductModel.fromJson(
        productJson,
      );

      debugPrint(
        'CREATED PRODUCT ID: ${product.id}',
      );

      await loadProducts(resolvedFarmId);

      return product;
    } catch (e) {
      debugPrint(
        'CREATE PRODUCT ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return null;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPLOAD PRODUCT IMAGE
  // ============================================================

  Future<bool> uploadProductImage({
    required String farmId,
    required String productId,
    required File imageFile,
  }) async {
    try {
      isUploadingImage.value = true;
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return false;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value =
            'Product ID is missing.';
        return false;
      }

      if (!await imageFile.exists()) {
        errorMessage.value =
            'Selected image does not exist.';
        return false;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('UPLOAD PRODUCT IMAGE');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint('IMAGE: ${imageFile.path}');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.postMultipart(
        'farmer/farms/$resolvedFarmId/products/'
        '$resolvedProductId/images',
        fields: {},
        files: {
          'image': imageFile.path,
        },
      );

      debugPrint(
        'IMAGE UPLOAD RESPONSE: $response',
      );

      final productJson =
          _extractProduct(response);

      if (productJson != null) {
        try {
          final updatedProduct =
              ProductModel.fromJson(productJson);

          final index = products.indexWhere(
            (product) =>
                product.id == updatedProduct.id,
          );

          if (index >= 0) {
            products[index] = updatedProduct;
            products.refresh();
          }
        } catch (e) {
          debugPrint(
            'IMAGE RESPONSE PRODUCT PARSE ERROR: $e',
          );
        }
      }

      await loadProducts(resolvedFarmId);

      debugPrint(
        'PRODUCT IMAGE UPLOAD SUCCESS',
      );

      return true;
    } catch (e) {
      debugPrint(
        'UPLOAD PRODUCT IMAGE ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================================================
  // SET PRIMARY PRODUCT IMAGE
  //
  // PUT:
  // farms/{farm}/products/{product}/images/{image}/primary
  // ============================================================

  Future<bool> setPrimaryImage({
    required String farmId,
    required String productId,
    required String imageId,
  }) async {
    try {
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();
      final resolvedImageId = imageId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return false;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value =
            'Product ID is missing.';
        return false;
      }

      if (resolvedImageId.isEmpty) {
        errorMessage.value =
            'Image ID is missing.';
        return false;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('SET PRIMARY PRODUCT IMAGE');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint('IMAGE ID: $resolvedImageId');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.put(
        'farmer/farms/$resolvedFarmId/products/'
        '$resolvedProductId/images/$resolvedImageId/primary',
      );

      debugPrint(
        'SET PRIMARY IMAGE RESPONSE: $response',
      );

      await fetchProduct(
        farmId: resolvedFarmId,
        productId: resolvedProductId,
      );

      return true;
    } catch (e) {
      debugPrint(
        'SET PRIMARY IMAGE ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return false;
    }
  }

  // ============================================================
  // DELETE PRODUCT IMAGE
  //
  // DELETE:
  // farms/{farm}/products/{product}/images/{image}
  // ============================================================

  Future<bool> deleteProductImage({
    required String farmId,
    required String productId,
    required String imageId,
  }) async {
    try {
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();
      final resolvedImageId = imageId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return false;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value =
            'Product ID is missing.';
        return false;
      }

      if (resolvedImageId.isEmpty) {
        errorMessage.value =
            'Image ID is missing.';
        return false;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('DELETE PRODUCT IMAGE');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint('IMAGE ID: $resolvedImageId');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.delete(
        'farmer/farms/$resolvedFarmId/products/'
        '$resolvedProductId/images/$resolvedImageId',
      );

      debugPrint(
        'DELETE IMAGE RESPONSE: $response',
      );

      await fetchProduct(
        farmId: resolvedFarmId,
        productId: resolvedProductId,
      );

      return true;
    } catch (e) {
      debugPrint(
        'DELETE PRODUCT IMAGE ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return false;
    }
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<bool> updateProduct({
    required String farmId,
    required String productId,
    Map<String, dynamic>? data,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? unit,
    double? quantityAvailable,
    DateTime? harvestDate,
    String? farmingMethod,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return false;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value =
            'Product ID is missing.';
        return false;
      }

      final body = <String, dynamic>{};

      if (data != null) {
        body.addAll(data);
      }

      if (categoryId != null) {
        final category =
            int.tryParse(categoryId.trim());

        if (category != null) {
          body['category_id'] = category;
        }
      }

      if (name != null) {
        body['name'] = name.trim();
      }

      if (description != null) {
        body['description'] =
            description.trim().isEmpty
                ? null
                : description.trim();
      }

      if (price != null) {
        body['price'] = price;
      }

      if (unit != null) {
        body['unit'] = unit.trim();
      }

      if (quantityAvailable != null) {
        body['quantity_available'] =
            quantityAvailable;
      }

      if (harvestDate != null) {
        body['harvest_date'] =
            _formatApiDate(harvestDate);
      }

      if (farmingMethod != null) {
        body['farming_method'] =
            farmingMethod.trim().isEmpty
                ? null
                : farmingMethod.trim();
      }

      if (isActive != null) {
        body['is_active'] = isActive;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('UPDATE PRODUCT');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint('BODY: $body');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.put(
        'farmer/farms/$resolvedFarmId/products/'
        '$resolvedProductId',
        body,
      );

      debugPrint(
        'UPDATE PRODUCT RESPONSE: $response',
      );

      final productJson =
          _extractProduct(response);

      if (productJson != null) {
        try {
          final updatedProduct =
              ProductModel.fromJson(productJson);

          final index = products.indexWhere(
            (product) =>
                product.id == updatedProduct.id,
          );

          if (index >= 0) {
            products[index] = updatedProduct;
            products.refresh();
          } else {
            products.add(updatedProduct);
          }
        } catch (e) {
          debugPrint(
            'UPDATED PRODUCT PARSE ERROR: $e',
          );
        }
      }

      await loadProducts(resolvedFarmId);

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE PRODUCT ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<bool> deleteProduct({
    required String farmId,
    required String productId,
  }) async {
    try {
      errorMessage.value = '';

      final resolvedFarmId = farmId.trim();
      final resolvedProductId = productId.trim();

      if (resolvedFarmId.isEmpty) {
        errorMessage.value = 'Farm ID is missing.';
        return false;
      }

      if (resolvedProductId.isEmpty) {
        errorMessage.value =
            'Product ID is missing.';
        return false;
      }

      debugPrint(
        '========================================',
      );
      debugPrint('DELETE PRODUCT');
      debugPrint('FARM ID: $resolvedFarmId');
      debugPrint('PRODUCT ID: $resolvedProductId');
      debugPrint(
        '========================================',
      );

      final response = await ApiClient.delete(
        'farmer/farms/$resolvedFarmId/products/'
        '$resolvedProductId',
      );

      debugPrint(
        'DELETE PRODUCT RESPONSE: $response',
      );

      products.removeWhere(
        (product) =>
            product.id == resolvedProductId,
      );

      return true;
    } catch (e) {
      debugPrint(
        'DELETE PRODUCT ERROR: $e',
      );

      errorMessage.value = _cleanError(e);

      return false;
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatApiDate(
    DateTime date,
  ) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Map<String, dynamic>? _extractProduct(
    dynamic response,
  ) {
    if (response is ProductModel) {
      return response.toJson();
    }

    if (response is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(
      response,
    );

    if (map['product'] is Map) {
      return Map<String, dynamic>.from(
        map['product'] as Map,
      );
    }

    if (map['data'] is Map) {
      final data =
          Map<String, dynamic>.from(
        map['data'] as Map,
      );

      if (data['product'] is Map) {
        return Map<String, dynamic>.from(
          data['product'] as Map,
        );
      }

      if (data['id'] != null) {
        return data;
      }
    }

    if (map['id'] != null) {
      return map;
    }

    return null;
  }

  // ============================================================
  // LIST RESPONSE HELPER
  // ============================================================

  List<dynamic> _extractList(
    dynamic response,
  ) {
    if (response is List) {
      return response;
    }

    if (response is! Map) {
      return [];
    }

    if (response['data'] is List) {
      return response['data'] as List;
    }

    if (response['products'] is List) {
      return response['products'] as List;
    }

    if (response['data'] is Map) {
      final data =
          Map<String, dynamic>.from(
        response['data'] as Map,
      );

      if (data['data'] is List) {
        return data['data'] as List;
      }

      if (data['products'] is List) {
        return data['products'] as List;
      }
    }

    return [];
  }

  // ============================================================
  // FARM RESPONSE HELPER
  // ============================================================

  Map<String, dynamic>? _extractFirstFarm(
    dynamic response,
  ) {
    if (response is List &&
        response.isNotEmpty &&
        response.first is Map) {
      return Map<String, dynamic>.from(
        response.first as Map,
      );
    }

    if (response is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(
      response,
    );

    if (map['data'] is List) {
      final data = map['data'] as List;

      if (data.isNotEmpty &&
          data.first is Map) {
        return Map<String, dynamic>.from(
          data.first as Map,
        );
      }
    }

    if (map['farms'] is List) {
      final farms = map['farms'] as List;

      if (farms.isNotEmpty &&
          farms.first is Map) {
        return Map<String, dynamic>.from(
          farms.first as Map,
        );
      }
    }

    if (map['farm'] is Map) {
      return Map<String, dynamic>.from(
        map['farm'] as Map,
      );
    }

    if (map['data'] is Map) {
      return Map<String, dynamic>.from(
        map['data'] as Map,
      );
    }

    if (map['id'] != null) {
      return map;
    }

    return null;
  }

  // ============================================================
  // READ STRING
  // ============================================================

  String? _readString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty ||
        result == 'null') {
      return null;
    }

    return result;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }
}