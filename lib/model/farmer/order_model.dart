class OrderModel {
  final String orderId;

  final String customerName;
  final String phone;
  final String address;

  final List<OrderItemModel> items;

  final double subtotal;
  final double deliveryFee;
  final double total;

  final String paymentMethod;
  final bool paymentVerified;

  final String status;
  final DateTime? createdAt;

  /// 0 = Pending
  /// 1 = Confirmed
  /// 2 = Packed
  /// 3 = Dispatched
  /// 4 = Out for Delivery
  /// 5 = Delivered
  /// 6 = Completed
  /// -1 = Cancelled
  final int fulfillmentStage;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentVerified,
    required this.status,
    this.createdAt,
    this.fulfillmentStage = 0,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = _map(json['user']);
    final payment = _map(json['payment']);

    final rawItems = json['items'];
    final parsedItems = <OrderItemModel>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          parsedItems.add(
            OrderItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final normalizedStatus = _normalizeStatus(
      json['status'],
    );

    return OrderModel(
      orderId: _string(
        json['id'] ??
            json['order_id'],
        fallback: 'Unknown',
      ),

      customerName: _string(
        user['name'] ??
            json['customer_name'] ??
            json['customerName'],
        fallback: 'Unknown Customer',
      ),

      phone: _string(
        user['phone'] ??
            json['phone'] ??
            json['customer_phone'] ??
            json['customerPhone'],
        fallback: 'No phone number',
      ),

      address: _string(
        json['delivery_address'] ??
            json['address'] ??
            json['deliveryAddress'],
        fallback: 'No delivery address',
      ),

      items: parsedItems,

      subtotal: _toDouble(
        json['subtotal'] ??
            json['subtotal_amount'],
      ),

      deliveryFee: _toDouble(
        json['delivery_fee'] ??
            json['deliveryFee'],
      ),

      total: _toDouble(
        json['total'] ??
            json['total_amount'],
      ),

      paymentMethod: _string(
        json['payment_method'] ??
            payment['payment_method'] ??
            payment['method'],
        fallback: 'Unknown',
      ),

      paymentVerified: _isPaymentVerified(
        payment,
      ),

      status: normalizedStatus,

      createdAt: _toDateTime(
        json['created_at'] ??
            json['createdAt'],
      ),

      fulfillmentStage:
          _statusToStage(normalizedStatus),
    );
  }

  // ============================================================
  // STATUS NORMALIZATION
  // ============================================================

  static String _normalizeStatus(
    dynamic value,
  ) {
    final status = value
        ?.toString()
        .trim()
        .toLowerCase();

    switch (status) {
      case 'pending':
        return 'pending';

      case 'confirmed':
        return 'confirmed';

      case 'packed':
        return 'packed';

      case 'preparing':
        return 'packed';

      case 'ready':
        return 'packed';

      case 'dispatched':
        return 'dispatched';

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return 'out_for_delivery';

      case 'delivered':
        return 'delivered';

      case 'completed':
        return 'completed';

      case 'cancelled':
      case 'canceled':
        return 'cancelled';

      default:
        return status ?? 'pending';
    }
  }

  // ============================================================
  // STATUS → STAGE
  // ============================================================

  static int _statusToStage(
    String status,
  ) {
    switch (status) {
      case 'pending':
        return 0;

      case 'confirmed':
        return 1;

      case 'packed':
        return 2;

      case 'dispatched':
        return 3;

      case 'out_for_delivery':
        return 4;

      case 'delivered':
        return 5;

      case 'completed':
        return 6;

      case 'cancelled':
        return -1;

      default:
        return 0;
    }
  }

  // ============================================================
  // DISPLAY STATUS
  // ============================================================

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'confirmed':
        return 'Confirmed';

      case 'packed':
        return 'Packed';

      case 'dispatched':
        return 'Dispatched';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return _capitalizeStatus(status);
    }
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isCancelled {
    return status == 'cancelled';
  }

  bool get isCompleted {
    return status == 'delivered' ||
        status == 'completed';
  }

  bool get isActive {
    return !isCancelled &&
        !isCompleted;
  }

  bool get isPending {
    return status == 'pending';
  }

  bool get isConfirmed {
    return status == 'confirmed';
  }

  bool get isPacked {
    return status == 'packed';
  }

  bool get isDispatched {
    return status == 'dispatched';
  }

  bool get isOutForDelivery {
    return status == 'out_for_delivery';
  }

  bool get isDelivered {
    return status == 'delivered';
  }

  // ============================================================
  // PAYMENT HELPERS
  // ============================================================

  bool get isPaid {
    return paymentVerified;
  }

  bool get isPaymentPending {
    return !paymentVerified;
  }

  // ============================================================
  // ITEM COUNT
  // ============================================================

  int get itemCount {
    return items.fold(
      0,
      (sum, item) =>
          sum + item.quantity.toInt(),
    );
  }

  // ============================================================
  // CALCULATED ITEM TOTAL
  // ============================================================

  double get calculatedItemsTotal {
    return items.fold(
      0.0,
      (sum, item) =>
          sum + item.lineTotal,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value
        .toString()
        .trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }

  static DateTime? _toDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static bool _isPaymentVerified(
    Map<String, dynamic> payment,
  ) {
    final status = payment['status']
        ?.toString()
        .trim()
        .toLowerCase();

    return status == 'paid' ||
        status == 'completed' ||
        status == 'confirmed';
  }

  static String _capitalizeStatus(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                  '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

// ============================================================================
// ORDER ITEM
// ============================================================================

class OrderItemModel {
  final String name;
  final String khmerName;

  /// Laravel stores this as decimal(12,2).
  final double quantity;

  final double price;

  OrderItemModel({
    required this.name,
    required this.khmerName,
    required this.quantity,
    required this.price,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory OrderItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = _map(
      json['product'],
    );

    return OrderItemModel(
      name: _string(
        product['name'] ??
            json['product_name'],
        fallback: 'Unknown Product',
      ),

      khmerName: _string(
        product['khmer_name'] ??
            json['khmer_name'],
      ),

      quantity: _toDouble(
        json['quantity'],
      ),

      price: _toDouble(
        json['price'] ??
            json['unit_price'] ??
            product['price'],
      ),
    );
  }

  // ============================================================
  // LINE TOTAL
  // ============================================================

  double get lineTotal {
    return price * quantity;
  }

  // ============================================================
  // DISPLAY QUANTITY
  // ============================================================

  String get displayQuantity {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }

    return quantity.toString();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value
        .toString()
        .trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }
}