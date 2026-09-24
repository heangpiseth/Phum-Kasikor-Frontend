import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/order_model.dart';

class OrderController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================

  final orders = <OrderModel>[].obs;

  final selectedOrder = Rxn<OrderModel>();

  final isLoading = false.obs;

  final isUpdating = false.obs;

  final errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // ============================================================
  // FILTERS
  // ============================================================

  List<OrderModel> get pendingOrders {
    return orders
        .where((order) => order.isPending)
        .toList();
  }

  List<OrderModel> get confirmedOrders {
    return orders
        .where((order) => order.isConfirmed)
        .toList();
  }

  List<OrderModel> get packedOrders {
    return orders
        .where((order) => order.isPacked)
        .toList();
  }

  List<OrderModel> get dispatchedOrders {
    return orders
        .where((order) => order.isDispatched)
        .toList();
  }

  List<OrderModel> get outForDeliveryOrders {
    return orders
        .where((order) => order.isOutForDelivery)
        .toList();
  }

  List<OrderModel> get deliveredOrders {
    return orders
        .where(
          (order) =>
              order.isDelivered ||
              order.status == 'completed',
        )
        .toList();
  }

  List<OrderModel> get cancelledOrders {
    return orders
        .where((order) => order.isCancelled)
        .toList();
  }

  List<OrderModel> get activeOrders {
    return orders
        .where((order) => order.isActive)
        .toList();
  }

  // ============================================================
  // PAYMENT / EARNINGS
  // ============================================================

  /// Total money actually marked as paid.
  ///
  /// This is intentionally NOT based on delivered/completed
  /// status because your project uses direct customer-to-farmer
  /// payment.
  double get totalEarnings {
    return orders
        .where(
          (order) =>
              order.paymentVerified &&
              !order.isCancelled,
        )
        .fold(
          0.0,
          (sum, order) => sum + order.total,
        );
  }

  double get pendingPaymentAmount {
    return orders
        .where(
          (order) =>
              !order.paymentVerified &&
              !order.isCancelled,
        )
        .fold(
          0.0,
          (sum, order) => sum + order.total,
        );
  }

  int get paidOrderCount {
    return orders
        .where(
          (order) =>
              order.paymentVerified &&
              !order.isCancelled,
        )
        .length;
  }

  // ============================================================
  // LOAD ALL ORDERS
  // ============================================================

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/orders',
      );

      final rawOrders = _extractOrders(response);

      final parsedOrders = <OrderModel>[];

      for (final item in rawOrders) {
        if (item is Map) {
          parsedOrders.add(
            OrderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      orders.assignAll(parsedOrders);
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  // ============================================================
  // LOAD SINGLE ORDER
  // ============================================================

  Future<OrderModel?> loadOrderDetail(
    String orderId,
  ) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/orders/$orderId',
      );

      final rawOrder = _extractOrderJson(response);

      if (rawOrder == null) {
        throw Exception(
          'Invalid order response.',
        );
      }

      final order = OrderModel.fromJson(
        rawOrder,
      );

      selectedOrder.value = order;

      _replaceOrder(order);

      return order;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return null;
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // CONFIRM ORDER
  //
  // PUT /api/farmer/orders/{order}/confirm
  // ============================================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final response = await ApiClient.put(
        'farmer/orders/$orderId/confirm',
        {},
      );

      final order = _extractOrder(response);

      if (order != null) {
        _replaceOrder(order);
        selectedOrder.value = order;
      } else {
        await loadOrderDetail(orderId);
      }

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  //
  // PUT /api/farmer/orders/{order}
  //
  // {
  //   "status": "packed"
  // }
  // ============================================================

  Future<bool> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final normalizedStatus = status.trim().toLowerCase();

    if (!_isValidStatus(normalizedStatus)) {
      errorMessage.value =
          'Invalid order status: $status';

      return false;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final response = await ApiClient.put(
        'farmer/orders/$orderId',
        {
          'status': normalizedStatus,
        },
      );

      final order = _extractOrder(response);

      if (order != null) {
        _replaceOrder(order);
        selectedOrder.value = order;
      } else {
        await loadOrderDetail(orderId);
      }

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // MARK PAYMENT AS PAID
  //
  // PUT /api/farmer/orders/{order}/mark-paid
  // ============================================================

  Future<bool> markPaymentPaid(
    String orderId,
  ) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final response = await ApiClient.put(
        'farmer/orders/$orderId/mark-paid',
        {},
      );

      final order = _extractOrder(response);

      if (order != null) {
        _replaceOrder(order);
        selectedOrder.value = order;
      } else {
        await loadOrderDetail(orderId);
      }

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ============================================================
  // MOVE TO NEXT STATUS
  // ============================================================

  Future<bool> moveToNextStatus(
    OrderModel order,
  ) async {
    switch (order.status) {
      case 'pending':
        return confirmOrder(
          order.orderId,
        );

      case 'confirmed':
        return updateOrderStatus(
          order.orderId,
          'packed',
        );

      case 'packed':
        return updateOrderStatus(
          order.orderId,
          'dispatched',
        );

      case 'dispatched':
        return updateOrderStatus(
          order.orderId,
          'out_for_delivery',
        );

      case 'out_for_delivery':
        return updateOrderStatus(
          order.orderId,
          'delivered',
        );

      case 'delivered':
        return updateOrderStatus(
          order.orderId,
          'completed',
        );

      default:
        return false;
    }
  }

  // ============================================================
  // GET ORDER BY ID
  // ============================================================

  OrderModel? getOrderById(
    String orderId,
  ) {
    try {
      return orders.firstWhere(
        (order) => order.orderId == orderId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<OrderModel> searchOrders(
    String query,
  ) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return orders.toList();
    }

    return orders.where((order) {
      return order.orderId
              .toLowerCase()
              .contains(search) ||
          order.customerName
              .toLowerCase()
              .contains(search) ||
          order.phone
              .toLowerCase()
              .contains(search) ||
          order.status
              .toLowerCase()
              .contains(search);
    }).toList();
  }

  // ============================================================
  // EXTRACT ORDERS
  // ============================================================

  List<dynamic> _extractOrders(
    dynamic response,
  ) {
    if (response is! Map) {
      return [];
    }

    final ordersData = response['orders'];

    if (ordersData is List) {
      return ordersData;
    }

    final data = response['data'];

    if (data is List) {
      return data;
    }

    if (data is Map) {
      final nestedOrders = data['orders'];

      if (nestedOrders is List) {
        return nestedOrders;
      }
    }

    return [];
  }

  // ============================================================
  // EXTRACT SINGLE ORDER
  // ============================================================

  OrderModel? _extractOrder(
    dynamic response,
  ) {
    final json = _extractOrderJson(response);

    if (json == null) {
      return null;
    }

    return OrderModel.fromJson(json);
  }

  Map<String, dynamic>? _extractOrderJson(
    dynamic response,
  ) {
    if (response is! Map) {
      return null;
    }

    final order = response['order'];

    if (order is Map) {
      return Map<String, dynamic>.from(order);
    }

    final data = response['data'];

    if (data is Map) {
      final nestedOrder = data['order'];

      if (nestedOrder is Map) {
        return Map<String, dynamic>.from(
          nestedOrder,
        );
      }

      if (_looksLikeOrder(data)) {
        return Map<String, dynamic>.from(data);
      }
    }

    if (_looksLikeOrder(response)) {
      return Map<String, dynamic>.from(response);
    }

    return null;
  }

  bool _looksLikeOrder(
    Map<dynamic, dynamic> value,
  ) {
    return value.containsKey('id') ||
        value.containsKey('order_id');
  }

  // ============================================================
  // REPLACE ORDER
  // ============================================================

  void _replaceOrder(
    OrderModel updatedOrder,
  ) {
    final index = orders.indexWhere(
      (order) =>
          order.orderId ==
          updatedOrder.orderId,
    );

    if (index == -1) {
      orders.insert(
        0,
        updatedOrder,
      );
    } else {
      orders[index] = updatedOrder;
    }

    orders.refresh();
  }

  // ============================================================
  // VALID STATUS
  // ============================================================

  bool _isValidStatus(
    String status,
  ) {
    const validStatuses = {
      'pending',
      'confirmed',
      'packed',
      'dispatched',
      'out_for_delivery',
      'delivered',
      'completed',
      'cancelled',
    };

    return validStatuses.contains(status);
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
    dynamic error,
  ) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    errorMessage.value = '';
  }

  // ============================================================
  // CLEAR SELECTED ORDER
  // ============================================================

  void clearSelectedOrder() {
    selectedOrder.value = null;
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  void clearOrders() {
    orders.clear();
    selectedOrder.value = null;
    errorMessage.value = '';
  }
}