import 'package:get/get.dart';

import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';
import 'package:phum_kasikors/core/service/customer/customer_checkout_service.dart';

class CheckoutController extends GetxController {
  late final CartController cart = Get.find<CartController>();

  final CustomerCheckoutService _service = CustomerCheckoutService();

  final deliveryAddress =
      'Channa Sok\nNo. 124, St. 51, Sangkat Boeung Keng Keng I,\n'
      'Khan Chamkarmon, Phnom Penh 12302'.obs;

  final deliveryMethod = DeliveryMethod.standard.obs;

  final selectedPayment =
      Rxn<PaymentMethod>(PaymentMethod.abaBank);

  final orderNote = ''.obs;

  final isPlacingOrder = false.obs;

  static const double expressFee = 3.0;
  static const double standardFee = 0.0;

  double get deliveryFee {
    return deliveryMethod.value == DeliveryMethod.express
        ? expressFee
        : standardFee;
  }

  double get total {
    return cart.subtotal + deliveryFee;
  }

  void setDeliveryMethod(DeliveryMethod method) {
    deliveryMethod.value = method;
  }

  void selectPayment(PaymentMethod method) {
    selectedPayment.value = method;
  }

  void editAddress() {
    Get.snackbar(
      'Delivery Address',
      'Address editing is not available yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> placeOrder() async {
    if (isPlacingOrder.value) {
      return;
    }

    if (cart.itemCount == 0) {
      Get.snackbar(
        'Cart is Empty',
        'Please add products to your cart first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (deliveryAddress.value.trim().isEmpty) {
      Get.snackbar(
        'Delivery Address',
        'Please enter your delivery address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final payment = selectedPayment.value;

    if (payment == null) {
      Get.snackbar(
        'Payment Method',
        'Please select a payment method.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPlacingOrder.value = true;

    try {
      final response = await _service.createOrder(
        items: cart.items
            .map(OrderItem.fromCartItem)
            .toList(),
        deliveryAddress: deliveryAddress.value,
        deliveryMethod: deliveryMethod.value,
        paymentMethod: payment,
        deliveryFee: deliveryFee,
        note: orderNote.value,
      );

      final OrderModel order = response.order;

      // The Laravel API has successfully created the order.
      // Clear the local cart now.
      cart.clearCart();

      Get.offAllNamed(
        AppRoutes.costumerOrderSuccessscreen,
        arguments: order,
      );
    } catch (e) {
      final message = _cleanErrorMessage(e);

      Get.snackbar(
        'Order Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  String _cleanErrorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return text;
  }
}