import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CustomerOrderController extends GetxController {
  final orders = <CustomerOrderModel>[].obs;

  final selectedOrder = Rxn<CustomerOrderModel>();

  final isLoading = false.obs;
  final isLoadingDetail = false.obs;
  final isCancelling = false.obs;

  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'customer/orders',
      );

      if (response is Map && response['orders'] is List) {
        final data = response['orders'] as List;

        orders.assignAll(
          data
              .whereType<Map>()
              .map(
                (item) => CustomerOrderModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else if (response is List) {
        orders.assignAll(
          response
              .whereType<Map>()
              .map(
                (item) => CustomerOrderModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else {
        orders.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<CustomerOrderModel?> loadOrder(
    String orderId,
  ) async {
    try {
      isLoadingDetail.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'customer/orders/$orderId',
      );

      CustomerOrderModel? order;

      if (response is Map) {
        final data = Map<String, dynamic>.from(response);

        if (data['order'] is Map) {
          order = CustomerOrderModel.fromJson(
            Map<String, dynamic>.from(data['order']),
          );
        } else if (data['id'] != null) {
          order = CustomerOrderModel.fromJson(data);
        }
      }

      selectedOrder.value = order;

      return order;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<bool> cancelOrder(
    String orderId,
  ) async {
    try {
      isCancelling.value = true;
      errorMessage.value = '';

      await ApiClient.post(
        'customer/orders/$orderId/cancel',
        {},
      );

      await loadOrders();

      if (selectedOrder.value?.id == orderId) {
        await loadOrder(orderId);
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  CustomerOrderModel? getOrderById(
    String orderId,
  ) {
    try {
      return orders.firstWhere(
        (order) => order.id == orderId,
      );
    } catch (_) {
      return null;
    }
  }
}