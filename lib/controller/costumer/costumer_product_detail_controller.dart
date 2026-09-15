import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';


class ProductDetailController extends GetxController {
  late final ProductModel product;
  final quantity = 1.obs;
  late final List<ReviewModel> reviews;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
    reviews = MockDataService.to.reviews;
  }

  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  double get totalPrice => product.price * quantity.value;

  void addToCart() {
    Get.find<CartController>().addProduct(product, quantity: quantity.value);
    Get.snackbar(
      'Added to cart',
      '${quantity.value} x ${product.name} added',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}