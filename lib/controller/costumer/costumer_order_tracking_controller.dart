import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class OrderTrackingController extends GetxController {
  late final OrderModel order;

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
    order = Get.arguments as OrderModel;
  }

  int get currentStepIndex => order.status.index;
}