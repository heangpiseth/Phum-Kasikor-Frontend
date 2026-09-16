import 'package:get/get.dart';

class CartItem {
  final dynamic product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice {
    return product.price * quantity;
  }

  double get lineTotal => totalPrice;

}

class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  void addProduct(dynamic product, {int quantity = 1}) {
    final index = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      items[index].quantity += quantity;
      items.refresh();
    } else {
      items.add(
        CartItem(
          product: product,
          quantity: quantity,
        ),
      );
    }

    Get.snackbar(
      'Cart',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  void removeProduct(String productId) {
    items.removeWhere(
      (item) => item.product.id == productId,
    );
  }

  // ============================================================
  // INCREASE
  // ============================================================

  void increaseQuantity(String productId) {
    final index = items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      items[index].quantity++;
      items.refresh();
    }
  }

  // ============================================================
  // DECREASE
  // ============================================================

  void decreaseQuantity(String productId) {
    final index = items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
      } else {
        items.removeAt(index);
      }
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearCart() {
    items.clear();
  }

  // ============================================================
  // TOTAL ITEMS
  // ============================================================

  int get totalItems {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  int get itemCount => totalItems;

  double get subtotal => totalPrice;

  // ============================================================
  // TOTAL PRICE
  // ============================================================

  double get totalPrice {
    return items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  // ============================================================
  // IS EMPTY
  // ============================================================

  bool get isEmpty => items.isEmpty;
}
