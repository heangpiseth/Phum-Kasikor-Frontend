import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/farmer_order_model.dart';

class FarmerOrderController extends GetxController {
  final orders = <FarmerOrderModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/orders',
      );

      if (response is Map &&
          response['orders'] is List) {
        orders.assignAll(
          (response['orders'] as List)
              .map(
                (item) =>
                    FarmerOrderModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else if (response is List) {
        orders.assignAll(
          response
              .map(
                (item) =>
                    FarmerOrderModel.fromJson(
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

  FarmerOrderModel? getOrderById(
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

  Future<FarmerOrderModel?> getOrder(
    String orderId,
  ) async {
    try {
      final response = await ApiClient.get(
        'farmer/orders/$orderId',
      );

      if (response is Map) {
        final data = Map<String, dynamic>.from(
          response,
        );

        if (data['order'] is Map) {
          return FarmerOrderModel.fromJson(
            Map<String, dynamic>.from(
              data['order'],
            ),
          );
        }

        if (data['id'] != null) {
          return FarmerOrderModel.fromJson(data);
        }
      }

      return null;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    return _updateOrder(
      orderId: orderId,
      endpoint: 'farmer/orders/$orderId/confirm',
    );
  }

  Future<bool> updateStatus({
    required String orderId,
    required String status,
  }) async {
    return _updateOrder(
      orderId: orderId,
      endpoint: 'farmer/orders/$orderId',
      body: {
        'status': status,
      },
    );
  }

  Future<bool> markPaymentPaid(
    String orderId,
  ) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      await ApiClient.put(
        'farmer/orders/$orderId/mark-paid',
        {},
      );

      await loadOrders();

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> _updateOrder({
    required String orderId,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final response = await ApiClient.put(
        endpoint,
        body ?? {},
      );

      FarmerOrderModel? updated;

      if (response is Map) {
        final data = Map<String, dynamic>.from(
          response,
        );

        if (data['order'] is Map) {
          updated = FarmerOrderModel.fromJson(
            Map<String, dynamic>.from(
              data['order'],
            ),
          );
        } else if (data['id'] != null) {
          updated =
              FarmerOrderModel.fromJson(data);
        }
      }

      if (updated != null) {
        final index = orders.indexWhere(
          (order) => order.id == orderId,
        );

        if (index != -1) {
          orders[index] = updated;
        } else {
          orders.add(updated);
        }
      } else {
        await loadOrders();
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}