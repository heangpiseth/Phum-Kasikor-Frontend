import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';
import 'package:phum_kasikors/core/service/customer/customer_order_service.dart';

class OrderTrackingController extends GetxController {
  final _service = CustomerOrderService();

  OrderModel? order;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

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
      // Fetch latest status from API
      fetchOrderDetail();
    }
  }

  int get currentStepIndex => order?.status.index ?? 0;

  Future<void> fetchOrderDetail() async {
    if (order == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _service.getOrderDetail(order!.id);
      order = response.order;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshStatus() => fetchOrderDetail();
}