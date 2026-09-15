import 'dart:async';

import 'package:get/get.dart';

import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_checkout_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class PaymentController extends GetxController {
  final checkout = Get.find<CheckoutController>();
  final cart = Get.find<CartController>();

  // =========================
  // PAYMENT COUNTDOWN
  // =========================

  final remainingSeconds = (15 * 60).obs;

  Timer? _timer;

  // =========================
  // ORDER
  // =========================

  late final OrderModel order;

  @override
  void onInit() {
    super.onInit();

    order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: cart.items.toList(),
      deliveryAddress: checkout.deliveryAddress.value,
      deliveryMethod: checkout.deliveryMethod.value,
      paymentMethod:
          checkout.selectedPayment.value ??
          PaymentMethod.abaBank,
      deliveryFee: checkout.deliveryFee,
      farmName: cart.items.isNotEmpty
          ? cart.items.first.product.farmName
          : '',
      farmerName: 'Sokha Vann',
      farmerPhone: '+855 12 345 678',
    );

    _startTimer();
  }

  // =========================
  // START TIMER
  // =========================

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds.value <= 0) {
          timer.cancel();
        } else {
          remainingSeconds.value--;
        }
      },
    );
  }

  // =========================
  // FORMATTED TIME
  // =========================

  String get formattedTime {
    final minutes =
        remainingSeconds.value ~/ 60;

    final seconds =
        remainingSeconds.value % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =========================
  // CONFIRM PAYMENT
  // =========================

  void confirmPaymentCompleted() {
    order.status = OrderStatus.paymentConfirmed;

    // Stop countdown
    _timer?.cancel();

    // Clear cart
    cart.clearCart();

    // Go to Order Success
    Get.offNamed(
      AppRoutes.costumerOrderSuccessscreen,
      arguments: order,
    );
  }

  // =========================
  // CANCEL ORDER
  // =========================

  void cancelOrder() {
    _timer?.cancel();
    Get.back();
  }

  // =========================
  // CLOSE
  // =========================

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
