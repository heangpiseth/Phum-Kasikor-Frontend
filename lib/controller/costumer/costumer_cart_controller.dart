import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_cart_item_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

/// Kept alive for the whole app session (registered as permanent in main.dart)
/// so the cart badge / contents survive navigation between tabs.
class CartController extends GetxController {
  final items = <CartItemModel>[].obs;
  final promoCode = ''.obs;
  final deliveryFee = 2.0.obs;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);
  double get total => subtotal + (items.isEmpty ? 0 : deliveryFee.value);

  void addProduct(ProductModel product, {int quantity = 1}) {
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index].quantity += quantity;
      items.refresh();
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }
  }

  void increment(String productId) {
    final item = items.firstWhereOrNull((i) => i.product.id == productId);
    if (item != null) {
      item.quantity++;
      items.refresh();
    }
  }

  void decrement(String productId) {
    final item = items.firstWhereOrNull((i) => i.product.id == productId);
    if (item != null) {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        items.remove(item);
      }
      items.refresh();
    }
  }

  void removeItem(String productId) {
    items.removeWhere((i) => i.product.id == productId);
  }

  void clearCart() => items.clear();

  void applyPromoCode(String code) {
    promoCode.value = code;
    // Hook real promo validation here.
    Get.snackbar('Promo code', 'Applied "$code"', snackPosition: SnackPosition.BOTTOM);
  }

  // TODO: verify the route constant name — used
  // AppRoutes.costumerCheckoutscreen to match app_pages.dart from earlier;
  // rename if your actual checkout route constant differs.
  void goToCheckout() => Get.toNamed(AppRoutes.costumerCheckoutscreen);
}