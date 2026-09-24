import 'dart:async';

import 'package:get/get.dart';

import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class PaymentController extends GetxController {
  final CartController cart = Get.find<CartController>();

  late final OrderModel order;

  static const int _windowSeconds = 15 * 60;

  final remainingSeconds = _windowSeconds.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is! OrderModel) {
      throw ArgumentError(
        'PaymentController expects an OrderModel in Get.arguments.',
      );
    }

    order = args;

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds.value <= 0) {
          timer.cancel();
          onWindowExpired();
        } else {
          remainingSeconds.value--;
        }
      },
    );
  }

  void onWindowExpired() {
    Get.snackbar(
      'Payment Window Expired',
      'Please place the order again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void confirmPaymentCompleted() {
    _timer?.cancel();

    order.status = OrderStatus.confirmed;

    cart.clearCart();

    Get.offNamed(
      AppRoutes.costumerOrderSuccessscreen,
      arguments: order,
    );
  }

  void cancelOrder() {
    _timer?.cancel();
    Get.back();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}