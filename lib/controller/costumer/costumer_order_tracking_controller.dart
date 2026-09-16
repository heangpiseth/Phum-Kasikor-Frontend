import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class OrderTrackingController extends GetxController {
  OrderModel? order;

  final steps = const [
    'Order Placed',
    'Payment Confirmed',
    'Preparing Order',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is OrderModel) {
      order = arguments;
    }
  }

  int get currentStepIndex => order?.status.index ?? 0;
}
