import 'package:get/get.dart';

class InventoryController extends GetxController {
  final items = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> fetchInventory() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    items.add(item);
  }

  Future<void> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < items.length) {
      items[index] = Map<String, dynamic>.from(items[index])
        ..['quantity'] = quantity;
      items.refresh();
    }
  }

  Future<void> removeItem(int index) async {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
    }
  }
}