import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CheckoutController extends GetxController {
  final cart = Get.find<CartController>();

  final deliveryAddress =
      'Channa Sok\nNo. 124, St. 51, Sangkat Boeung Keng Kang I,\n'
              'Khan Chamkarmon, Phnom Penh 12302'
          .obs;
  final deliveryMethod = DeliveryMethod.standard.obs;
  final selectedPayment = Rxn<PaymentMethod>(PaymentMethod.abaBank);
  final orderNote = ''.obs;

  double get expressFee => 3.0;
  double get standardFee => 2.0;

  double get deliveryFee =>
      deliveryMethod.value == DeliveryMethod.express ? expressFee : standardFee;

  double get total => cart.subtotal + deliveryFee;

  void setDeliveryMethod(DeliveryMethod method) =>
      deliveryMethod.value = method;

  void selectPayment(PaymentMethod method) => selectedPayment.value = method;

  void placeOrder() {
    // Check cart if (cart.itemCount == 0) { Get.snackbar( 'Cart is Empty', 'Please add products to your cart first.', snackPosition: SnackPosition.BOTTOM, ); return; } // Check delivery address if (deliveryAddress.value.trim().isEmpty) { Get.snackbar( 'Delivery Address', 'Please enter your delivery address.', snackPosition: SnackPosition.BOTTOM, ); return; } // Calculate order information final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}'; final order = OrderModel( id: orderId, items: cart.items, subtotal: cart.subtotal, deliveryFee: deliveryMethod.value == DeliveryMethod.express ? 3.00 : 0.00, total: total, paymentMethod: selectedPayment.value.label, status: 'Pending', deliveryMethod: deliveryMethod.value.label, address: deliveryAddress.value, createdAt: DateTime.now(), ); // Show success message Get.snackbar( 'Order Placed', 'Your order has been placed successfully.', snackPosition: SnackPosition.BOTTOM, ); // Navigate to Order Success screen Get.toNamed( AppRoutes.costumerOrderSuccessscreen, arguments: order, );
  }
}
