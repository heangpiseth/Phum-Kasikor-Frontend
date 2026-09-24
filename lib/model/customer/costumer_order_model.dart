import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';

enum DeliveryMethod {
  standard,
  express,
}

extension DeliveryMethodExtension on DeliveryMethod {
  String get label {
    switch (this) {
      case DeliveryMethod.standard:
        return 'Standard';
      case DeliveryMethod.express:
        return 'Express';
    }
  }

  String get subtitle {
    switch (this) {
      case DeliveryMethod.standard:
        return '2-3 Days • Free';
      case DeliveryMethod.express:
        return 'Same Day • \$3.00';
    }
  }

  String get apiValue {
    switch (this) {
      case DeliveryMethod.standard:
        return 'standard';
      case DeliveryMethod.express:
        return 'express';
    }
  }
}

enum PaymentMethod {
  abaBank,
  cashOnDelivery,
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.abaBank:
        return 'ABA Bank';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.abaBank:
        return 'Pay securely with ABA Bank';
      case PaymentMethod.cashOnDelivery:
        return 'Pay when your order arrives';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.abaBank:
        return 'aba';
      case PaymentMethod.cashOnDelivery:
        return 'cash_on_delivery';
    }
  }

  String get displayStatus {
    return label;
  }
}

enum OrderStatus {
  pending,
  confirmed,
  packed,
  dispatched,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';

      case OrderStatus.confirmed:
        return 'Confirmed';

      case OrderStatus.packed:
        return 'Packed';

      case OrderStatus.dispatched:
        return 'Dispatched';

      case OrderStatus.outForDelivery:
        return 'Out for Delivery';

      case OrderStatus.delivered:
        return 'Delivered';

      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get displayStatus {
    return label;
  }

  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
      case 'payment_confirmed':
      case 'paymentconfirmed':
      case 'paid':
        return OrderStatus.confirmed;

      case 'packed':
        return OrderStatus.packed;

      case 'dispatched':
      case 'shipping':
        return OrderStatus.dispatched;

      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;

      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;

      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;

      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItem {
  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  double get subtotal => price * quantity;

  /// Compatibility getter for existing order screens.
  ///
  /// Existing screens use item.product.name / item.product.imageUrl.
  /// We provide a lightweight product object here.
  OrderProduct get product {
    return OrderProduct(
      id: productId,
      name: productName,
      price: price,
      imageUrl: imageUrl,
    );
  }

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.product.id.toString(),
      productName: item.product.name,
      quantity: item.quantity,
      price: item.product.price,
      imageUrl: item.product.imageUrl,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];

    final productMap = product is Map
        ? Map<String, dynamic>.from(product)
        : <String, dynamic>{};

    return OrderItem(
      productId: (
        json['product_id'] ??
        productMap['id'] ??
        ''
      ).toString(),
      productName: (
        json['product_name'] ??
        productMap['name'] ??
        'Product'
      ).toString(),
      quantity: _toInt(json['quantity']),
      price: _toDouble(
        json['price'] ??
        json['unit_price'] ??
        productMap['price'],
      ),
      imageUrl: (
        json['image_url'] ??
        productMap['image_url'] ??
        productMap['image']
      )?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

/// Lightweight product information used by existing order screens.
class OrderProduct {
  const OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String? imageUrl;
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.deliveryFee,
    this.farmName = '',
    this.farmerName = '',
    this.farmerPhone = '',
    this.note = '',
    this.status = OrderStatus.pending,
  });

  final String id;
  final DateTime date;
  final List<OrderItem> items;

  final String deliveryAddress;
  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;
  final double deliveryFee;

  final String farmName;
  final String farmerName;
  final String farmerPhone;
  final String note;

  OrderStatus status;

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  int get itemCount {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get total {
    return subtotal + deliveryFee;
  }

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => OrderItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <OrderItem>[];

    return OrderModel(
      id: (
        json['id'] ??
        json['order_id'] ??
        ''
      ).toString(),
      date: _parseDate(
        json['date'] ??
        json['created_at'] ??
        json['createdAt'],
      ),
      items: items,
      deliveryAddress: (
        json['delivery_address'] ??
        json['deliveryAddress'] ??
        ''
      ).toString(),
      deliveryMethod: _deliveryMethodFromString(
        json['delivery_method']?.toString(),
      ),
      paymentMethod: _paymentMethodFromString(
        json['payment_method']?.toString(),
      ),
      deliveryFee: _toDouble(
        json['delivery_fee'],
      ),
      farmName: (
        json['farm_name'] ??
        json['farmName'] ??
        ''
      ).toString(),
      farmerName: (
        json['farmer_name'] ??
        json['farmerName'] ??
        ''
      ).toString(),
      farmerPhone: (
        json['farmer_phone'] ??
        json['farmerPhone'] ??
        ''
      ).toString(),
      note: (
        json['note'] ??
        json['notes'] ??
        ''
      ).toString(),
      status: OrderStatusExtension.fromString(
        json['status']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items
          .map((item) => item.toJson())
          .toList(),
      'delivery_address': deliveryAddress,
      'delivery_method': deliveryMethod.apiValue,
      'payment_method': paymentMethod.apiValue,
      'delivery_fee': deliveryFee,
      'farm_name': farmName,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'note': note,
      'status': status.label,
    };
  }

  static DeliveryMethod _deliveryMethodFromString(
    String? value,
  ) {
    switch (value?.toLowerCase()) {
      case 'express':
        return DeliveryMethod.express;

      case 'standard':
      default:
        return DeliveryMethod.standard;
    }
  }

  static PaymentMethod _paymentMethodFromString(
    String? value,
  ) {
    switch (value?.toLowerCase()) {
      case 'cash':
      case 'cash_on_delivery':
      case 'cashondelivery':
        return PaymentMethod.cashOnDelivery;

      case 'aba':
      case 'aba_bank':
      case 'ababank':
      default:
        return PaymentMethod.abaBank;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        DateTime.now();
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class CustomerOrderModel {
  CustomerOrderModel({
    required this.id,
    this.status = OrderStatus.pending,
    this.total = 0,
    this.items = const [],
    this.deliveryAddress = '',
    this.deliveryMethod = DeliveryMethod.standard,
    this.paymentMethod = PaymentMethod.abaBank,
    this.deliveryFee = 0,
    this.farmName = '',
    this.farmerName = '',
    this.farmerPhone = '',
    this.note = '',
    this.date,
  });

  final String id;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;

  final String deliveryAddress;
  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;
  final double deliveryFee;

  final String farmName;
  final String farmerName;
  final String farmerPhone;
  final String note;

  final DateTime? date;

  /// Compatibility getter used by the order screens.
  DateTime? get createdAt => date;

  /// Compatibility getter used by the order screens.
  double get totalAmount => total;

  /// Compatibility getter used by the order screens.
  int get itemCount {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  /// Compatibility getter used by the order screens.
  String get displayStatus => status.label;

  /// Compatibility getter used by the order screens.
  PaymentMethod get payment => paymentMethod;

  /// Orders can be cancelled while pending or payment-confirmed.
  bool get canCancel {
    return status == OrderStatus.pending ||
        status == OrderStatus.confirmed;
  }

  factory CustomerOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'];

    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => OrderItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <OrderItem>[];

    final deliveryFee = _toDouble(
      json['delivery_fee'],
    );

    final apiTotal = _toDouble(
      json['total'] ??
      json['total_amount'],
    );

    final subtotal = parsedItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return CustomerOrderModel(
      id: (
        json['id'] ??
        json['order_id'] ??
        ''
      ).toString(),
      status: OrderStatusExtension.fromString(
        json['status']?.toString(),
      ),
      total: apiTotal == 0
          ? subtotal + deliveryFee
          : apiTotal,
      items: parsedItems,
      deliveryAddress: (
        json['delivery_address'] ??
        json['deliveryAddress'] ??
        ''
      ).toString(),
      deliveryMethod: OrderModel._deliveryMethodFromString(
        json['delivery_method']?.toString(),
      ),
      paymentMethod: OrderModel._paymentMethodFromString(
        json['payment_method']?.toString(),
      ),
      deliveryFee: deliveryFee,
      farmName: (
        json['farm_name'] ??
        json['farmName'] ??
        ''
      ).toString(),
      farmerName: (
        json['farmer_name'] ??
        json['farmerName'] ??
        ''
      ).toString(),
      farmerPhone: (
        json['farmer_phone'] ??
        json['farmerPhone'] ??
        ''
      ).toString(),
      note: (
        json['note'] ??
        json['notes'] ??
        ''
      ).toString(),
      date: OrderModel._parseDate(
        json['date'] ??
        json['created_at'] ??
        json['createdAt'],
      ),
    );
  }

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

    static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
