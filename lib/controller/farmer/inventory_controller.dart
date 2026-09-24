import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/inventory_model.dart';

class InventoryController extends GetxController {
  final RxList<InventoryModel> items = <InventoryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  String? currentFarmId;

  // ============================================================
  // LOAD INVENTORY
  // ============================================================

  Future<void> loadInventory(String farmId) async {
    if (farmId.trim().isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      items.clear();
      return;
    }

    currentFarmId = farmId;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.get(
        'farmer/farms/$farmId/inventory',
      );

      final dynamic data = response['inventory'];

      if (data is List) {
        items.assignAll(
          data
              .whereType<Map>()
              .map(
                (item) => InventoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else {
        items.clear();
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE
  // IMPORTANT:
  // DO NOT reload inventory here.
  // The screen handles reload AFTER the dialog closes.
  // ============================================================

  Future<bool> createItem({
    required String farmId,
    String? categoryId,
    required String name,
    double? quantity,
    String? unit,
    double? minimumStock,
    String? status,
  }) async {
    if (farmId.trim().isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      await ApiClient.post(
        'farmer/farms/$farmId/inventory',
        {
          'category_id': _parseId(categoryId),
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'minimum_stock': minimumStock,
          'status': status,
        },
      );

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> updateItem({
    required String farmId,
    required String itemId,
    String? categoryId,
    String? name,
    double? quantity,
    String? unit,
    double? minimumStock,
    String? status,
  }) async {
    if (farmId.trim().isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    if (itemId.trim().isEmpty) {
      errorMessage.value = 'Inventory item ID is missing.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      await ApiClient.put(
        'farmer/farms/$farmId/inventory/$itemId',
        {
          'category_id': _parseId(categoryId),
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'minimum_stock': minimumStock,
          'status': status,
        },
      );

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> deleteItem({
    required String farmId,
    required String itemId,
  }) async {
    if (farmId.trim().isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    if (itemId.trim().isEmpty) {
      errorMessage.value = 'Inventory item ID is missing.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await ApiClient.delete(
        'farmer/farms/$farmId/inventory/$itemId',
      );

      items.removeWhere(
        (item) => item.id == itemId,
      );

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FIND ITEM
  // ============================================================

  InventoryModel? getItemById(String itemId) {
    try {
      return items.firstWhere(
        (item) => item.id == itemId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // STOCK HELPERS
  // ============================================================

  List<InventoryModel> get lowStockItems {
    return items
        .where((item) => item.isLowStock)
        .toList();
  }

  List<InventoryModel> get outOfStockItems {
    return items
        .where((item) => item.isOutOfStock)
        .toList();
  }

  int get lowStockCount {
    return lowStockItems.length;
  }

  int get outOfStockCount {
    return outOfStockItems.length;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  dynamic _parseId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return int.tryParse(value) ?? value;
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }
}