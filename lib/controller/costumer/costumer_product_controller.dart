import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

enum ProductCategory {
  all,
  vegetables,
  fruits,
  rice,
  herbs,
  dairy,
  processed,
  organic,
  specialty,
}

enum SortOrder {
  priceLowHigh,
  priceHighLow,
  nameAZ,
}

extension SortOrderX on SortOrder {
  String get label {
    switch (this) {
      case SortOrder.priceLowHigh:
        return 'Price Low-High';

      case SortOrder.priceHighLow:
        return 'Price High-Low';

      case SortOrder.nameAZ:
        return 'Name A-Z';
    }
  }
}

class FarmProductsController extends GetxController {
  FarmProductsController({
    required this._allProducts,
  });

  final List<ProductModel> _allProducts;

  final Rx<ProductCategory> selectedCategory =
      ProductCategory.all.obs;

  final Rx<SortOrder> sortOrder =
      SortOrder.priceLowHigh.obs;

  final RxSet<String> cartProductIds =
      <String>{}.obs;

  List<ProductModel> get visibleProducts {
    List<ProductModel> filtered;

    if (selectedCategory.value == ProductCategory.all) {
      filtered = List<ProductModel>.from(_allProducts);
    } else {
      filtered = _allProducts.where((product) {
        return product.category.name.toLowerCase() ==
            selectedCategory.value.name.toLowerCase();
      }).toList();
    }

    switch (sortOrder.value) {
      case SortOrder.priceLowHigh:
        filtered.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case SortOrder.priceHighLow:
        filtered.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case SortOrder.nameAZ:
        filtered.sort(
          (a, b) => a.name.compareTo(b.name),
        );
        break;
    }

    return filtered;
  }

  String get sortLabel => sortOrder.value.label;

  int get cartCount => cartProductIds.length;

  void selectCategory(ProductCategory category) {
    if (selectedCategory.value == category) {
      return;
    }

    selectedCategory.value = category;
  }

  void cycleSortOrder() {
    final values = SortOrder.values;

    final currentIndex =
        values.indexOf(sortOrder.value);

    final nextIndex =
        (currentIndex + 1) % values.length;

    sortOrder.value = values[nextIndex];
  }

  bool isInCart(String productId) {
    return cartProductIds.contains(productId);
  }

  void addToCart(ProductModel product) {
    cartProductIds.add(product.id);
    Get.find<CartController>().addProduct(product);
  }

  void removeFromCart(ProductModel product) {
    cartProductIds.remove(product.id);
    Get.find<CartController>().removeProduct(product.id);
  }

  void clearCart() {
    cartProductIds.clear();
  }
}

