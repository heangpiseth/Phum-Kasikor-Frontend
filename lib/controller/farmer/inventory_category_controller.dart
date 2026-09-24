import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/inventory_category_model.dart';

class InventoryCategoryController extends GetxController {
  final RxList<InventoryCategoryModel> categories =
      <InventoryCategoryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxString errorMessage = ''.obs;

  String? currentFarmId;

  Future<void> loadCategories(String farmId) async {
    currentFarmId = farmId;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.get(
        'farmer/farms/$farmId/inventory/categories',
      );

      final data = response is List
          ? response
          : response['categories'];

      if (data is List) {
        categories.assignAll(
          data
              .whereType<Map<String, dynamic>>()
              .map(InventoryCategoryModel.fromJson)
              .toList(),
        );
      } else {
        categories.clear();
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE CATEGORY
  // ============================================================

  Future<InventoryCategoryModel?> createCategory({
    required String farmId,
    required String name,
    String? icon,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.post(
        'farmer/farms/$farmId/inventory/categories',
        {
          'name': name,
          'icon': icon,
        },
      );

      final category = InventoryCategoryModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      categories.add(category);

      categories.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      return category;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // FIND CATEGORY
  // IMPORTANT: categoryId MUST BE NULLABLE
  // ============================================================

  InventoryCategoryModel? getCategoryById(
    String? categoryId,
  ) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return null;
    }

    try {
      return categories.firstWhere(
        (category) => category.id == categoryId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}