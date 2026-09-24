import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

class SortOrder {
  const SortOrder._(this.name, this.label);
  final String name;
  final String label;

  static const priceLowHigh = SortOrder._('priceLowHigh', 'Price Low-High');
  static const priceHighLow = SortOrder._('priceHighLow', 'Price High-Low');
  static const nameAZ = SortOrder._('nameAZ', 'Name A-Z');

  static const List<SortOrder> values = [
    priceLowHigh,
    priceHighLow,
    nameAZ,
  ];
}

class FarmProductsController extends GetxController {
  FarmProductsController({
    required this._allProducts,
  });

  final List<ProductModel> _allProducts;

  final Rxn<String> selectedCategory = Rxn<String>();

  final Rx<SortOrder> sortOrder = SortOrder.priceLowHigh.obs;

  final RxSet<String> cartProductIds = <String>{}.obs;

  List<String> get availableCategories {
    final categories = _allProducts
        .map((p) => p.category?.name)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  List<ProductModel> get visibleProducts {
    List<ProductModel> filtered;

    if (selectedCategory.value == null || selectedCategory.value == 'All') {
      filtered = List<ProductModel>.from(_allProducts);
    } else {
      filtered = _allProducts.where((product) {
        final catName = product.category?.name.toLowerCase() ?? '';
        return catName == selectedCategory.value!.toLowerCase();
      }).toList();
    }

    switch (sortOrder.value) {
      case SortOrder.priceLowHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOrder.priceHighLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOrder.nameAZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  String get sortLabel => sortOrder.value.label;

  int get cartCount => cartProductIds.length;

  void selectCategory(String? category) {
    if (selectedCategory.value == category) {
      return;
    }
    selectedCategory.value = category;
  }

  void cycleSortOrder() {
    final values = SortOrder.values;
    final currentIndex = values.indexOf(sortOrder.value);
    final nextIndex = (currentIndex + 1) % values.length;
    sortOrder.value = values[nextIndex];
  }

  bool isInCart(String productId) {
    return cartProductIds.contains(productId);
  }

  void addToCart(ProductModel product) {
    cartProductIds.add(product.id.toString());
    Get.find<CartController>().addProduct(product);
  }

  void removeFromCart(ProductModel product) {
    cartProductIds.remove(product.id.toString());
    Get.find<CartController>().removeProduct(product.id.toString());
  }

  void clearCart() {
    cartProductIds.clear();
  }
}