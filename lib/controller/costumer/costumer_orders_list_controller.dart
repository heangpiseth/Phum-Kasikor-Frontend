import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';


class OrdersListController extends GetxController {
  // Demo order history — replace with a real orders API/service later.
  final orders = <OrderModel>[].obs;

  void openTracking(OrderModel order) =>
      Get.toNamed(AppRoutes.costumerOrderTrackingscreen, arguments: order);

  void addOrder(OrderModel order) => orders.insert(0, order);
}
