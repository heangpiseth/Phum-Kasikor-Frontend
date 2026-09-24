import 'package:get/get.dart';

import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

class ProductDetailController extends GetxController {
  late final ProductModel product;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final CustomerProductRepository repository =
      Get.find<CustomerProductRepository>();

  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is! ProductModel) {
      throw ArgumentError(
        'ProductDetailController expects a ProductModel in Get.arguments.',
      );
    }

    product = args;

    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final result = await repository.getProductReviews(product.id);
      reviews.assignAll(result);
    } catch (_) {
      // Reviews are optional.
      // The product page should still work if reviews fail.
      reviews.clear();
    }
  }

  void increment() {
    final available = product.quantityAvailable;

    if (quantity.value >= available) {
      Get.snackbar(
        'Stock limit',
        'Only ${_formatQuantity(available)} ${product.unit} available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  double get totalPrice {
    return product.price * quantity.value;
  }

  bool get isOutOfStock {
    return product.quantityAvailable <= 0;
  }

  void addToCart() {
    if (isOutOfStock) {
      Get.snackbar(
        'Out of stock',
        '${product.name} is currently unavailable.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (quantity.value > product.quantityAvailable) {
      quantity.value = product.quantityAvailable.toInt();

      if (quantity.value < 1) {
        quantity.value = 1;
      }
    }

    Get.find<CartController>().addProduct(
      product,
      quantity: quantity.value,
    );

    Get.snackbar(
      'Added to cart',
      '${quantity.value} × ${product.name} added to your cart.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}