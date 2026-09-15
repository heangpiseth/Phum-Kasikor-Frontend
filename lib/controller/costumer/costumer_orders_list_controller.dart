import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';


class OrdersListController extends GetxController {
  // Demo order history — replace with a real orders API/service later.
  final orders = <OrderModel>[].obs;

  void openTracking(OrderModel order, dynamic Routes) =>
      Get.toNamed(Routes.orderTracking, arguments: order);
}