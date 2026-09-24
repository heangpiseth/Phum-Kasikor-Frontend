import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/core/service/customer/costumer_cart_service.dart';

class CartItem {
  final dynamic product;

  int quantity;

  /// ID returned by Laravel's cart_items table.
  ///
  /// This is NOT the product ID.
  int? cartItemId;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.cartItemId,
  });

  double get totalPrice {
    return (product.price as num).toDouble() * quantity;
  }

  double get lineTotal => totalPrice;
}

class CartController extends GetxController {
  // ============================================================
  // SERVICE
  // ============================================================

  final CustomerCartService _service =
      CustomerCartService();

  // ============================================================
  // STATE
  // ============================================================

  final RxList<CartItem> items =
      <CartItem>[].obs;

  final RxBool isLoading =
      false.obs;

  final RxBool isUpdating =
      false.obs;

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<bool> addProduct(
    dynamic product, {
    int quantity = 1,
  }) async {
    final productId = _getProductId(product);

    if (productId == null) {
      Get.snackbar(
        'Cart Error',
        'This product does not have a valid ID.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    if (quantity <= 0) {
      return false;
    }

    try {
      isUpdating.value = true;

      // ========================================================
      // IMPORTANT:
      // FIRST save to Laravel
      // ========================================================

      final response = await _service.addItem(
        productId: productId,
        quantity: quantity,
      );

      // Laravel returns:
      //
      // {
      //   "success": true,
      //   "item": {
      //      "id": 1,
      //      "cart_id": 2,
      //      "product_id": 5,
      //      ...
      //   }
      // }

      final serverItem =
          response['item']
              as Map<String, dynamic>?;

      final serverCartItemId =
          _toInt(serverItem?['id']);

      // ========================================================
      // THEN update local UI
      // ========================================================

      final index = items.indexWhere(
        (item) =>
            _getProductId(item.product) ==
            productId,
      );

      if (index != -1) {
        items[index].quantity += quantity;

        if (serverCartItemId != null) {
          items[index].cartItemId =
              serverCartItemId;
        }

        items.refresh();
      } else {
        items.add(
          CartItem(
            product: product,
            quantity: quantity,
            cartItemId: serverCartItemId,
          ),
        );
      }

      Get.snackbar(
        'Cart',
        '${product.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  Future<void> removeProduct(
    String productId,
  ) async {
    final id = int.tryParse(productId);

    if (id == null) {
      return;
    }

    final index = items.indexWhere(
      (item) =>
          _getProductId(item.product) == id,
    );

    if (index == -1) {
      return;
    }

    final item = items[index];

    if (item.cartItemId == null) {
      items.removeAt(index);
      return;
    }

    try {
      isUpdating.value = true;

      await _service.removeItem(
        item.cartItemId!,
      );

      items.removeAt(index);
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // INCREASE
  // ============================================================

  Future<void> increaseQuantity(
    String productId,
  ) async {
    final id = int.tryParse(productId);

    if (id == null) {
      return;
    }

    final index = items.indexWhere(
      (item) =>
          _getProductId(item.product) == id,
    );

    if (index == -1) {
      return;
    }

    final item = items[index];

    if (item.cartItemId == null) {
      return;
    }

    final newQuantity =
        item.quantity + 1;

    try {
      isUpdating.value = true;

      await _service.updateItem(
        cartItemId: item.cartItemId!,
        quantity: newQuantity,
      );

      item.quantity = newQuantity;

      items.refresh();
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // DECREASE
  // ============================================================

  Future<void> decreaseQuantity(
    String productId,
  ) async {
    final id = int.tryParse(productId);

    if (id == null) {
      return;
    }

    final index = items.indexWhere(
      (item) =>
          _getProductId(item.product) == id,
    );

    if (index == -1) {
      return;
    }

    final item = items[index];

    if (item.quantity <= 1) {
      await removeProduct(productId);
      return;
    }

    if (item.cartItemId == null) {
      return;
    }

    final newQuantity =
        item.quantity - 1;

    try {
      isUpdating.value = true;

      await _service.updateItem(
        cartItemId: item.cartItemId!,
        quantity: newQuantity,
      );

      item.quantity = newQuantity;

      items.refresh();
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearCart() async {
    try {
      isUpdating.value = true;

      await _service.clearCart();

      items.clear();
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // TOTAL ITEMS
  // ============================================================

  int get totalItems {
    return items.fold(
      0,
      (sum, item) =>
          sum + item.quantity,
    );
  }

  int get itemCount => totalItems;

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double get subtotal {
    return items.fold(
      0,
      (sum, item) =>
          sum + item.totalPrice,
    );
  }

  // ============================================================
  // TOTAL PRICE
  // ============================================================

  double get totalPrice => subtotal;

  // ============================================================
  // EMPTY
  // ============================================================

  bool get isEmpty => items.isEmpty;

  // ============================================================
  // PRODUCT ID
  // ============================================================

  int? _getProductId(
    dynamic product,
  ) {
    final value = product.id;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // INT CONVERTER
  // ============================================================

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}