import 'package:get/get.dart';

import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CheckoutController extends GetxController {
  late final CartController cart = Get.find<CartController>();

  final deliveryAddress =
      'Channa Sok\nNo. 124, St. 51, Sangkat Boeung Keng Kang I,\n'
      'Khan Chamkarmon, Phnom Penh 12302'.obs;

  final deliveryMethod = DeliveryMethod.standard.obs;
  final selectedPayment = Rxn<PaymentMethod>(PaymentMethod.abaBank);
  final orderNote = ''.obs;

  static const double expressFee = 3.0;
  static const double standardFee = 0.0; // UI says "2-3 Days • Free"

  double get deliveryFee =>
      deliveryMethod.value == DeliveryMethod.express ? expressFee : standardFee;

  double get total => cart.subtotal + deliveryFee;

  void setDeliveryMethod(DeliveryMethod method) => deliveryMethod.value = method;

  void selectPayment(PaymentMethod method) => selectedPayment.value = method;

  void editAddress() {
    Get.snackbar(
      'Delivery Address',
      'Address editing is not available yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void placeOrder() {
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

    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: cart.items.map(OrderItem.fromCartItem).toList(),
      deliveryAddress: deliveryAddress.value,
      deliveryMethod: deliveryMethod.value,
      paymentMethod: payment,
      deliveryFee: deliveryFee,
      farmName: cart.items.isNotEmpty ? cart.items.first.product.farmName : '',
      farmerName: 'Sokha Vann',
      farmerPhone: '+855 12 345 678',
      note: orderNote.value,
    );

    // Payment screen owns the countdown, cart clearing and the
    // hand-off to Order Success.
    Get.toNamed(AppRoutes.costumerPaymentscreen, arguments: order);
  }
}
