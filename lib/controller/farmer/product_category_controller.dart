import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/product_category_model.dart';

class ProductCategoryController extends GetxController {
  final categories = <ProductCategoryModel>[].obs;

  final selectedCategoryId = RxnString();

  final isLoading = false.obs;
  final isSaving = false.obs;

  final errorMessage = ''.obs;

  Future<void> loadCategories(String farmId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/farms/$farmId/products/categories',
      );

      if (response is List) {
        categories.assignAll(
          response
              .map(
                (item) => ProductCategoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else if (
          response is Map &&
          response['categories'] is List) {
        categories.assignAll(
          (response['categories'] as List)
              .map(
                (item) => ProductCategoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else {
        categories.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  ProductCategoryModel? getCategoryById(
    String categoryId,
  ) {
    try {
      return categories.firstWhere(
        (category) => category.id == categoryId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> createCategory({
    required String farmId,
    required String name,
    String? image,
    String? parentId,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final body = <String, dynamic>{
        'name': name,
        if (image != null && image.trim().isNotEmpty)
          'image': image,
        if (parentId != null)
          'parent_id': parentId,
      };

      final response = await ApiClient.post(
        'farmer/farms/$farmId/products/categories',
        body,
      );

      ProductCategoryModel? createdCategory;

      if (response is Map) {
        final data =
            Map<String, dynamic>.from(response);

        if (data['category'] is Map) {
          createdCategory =
              ProductCategoryModel.fromJson(
            Map<String, dynamic>.from(
              data['category'],
            ),
          );
        } else if (data['id'] != null) {
          createdCategory =
              ProductCategoryModel.fromJson(data);
        }
      }

      if (createdCategory != null) {
        categories.add(createdCategory);
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void clearSelection() {
    selectedCategoryId.value = null;
  }
}