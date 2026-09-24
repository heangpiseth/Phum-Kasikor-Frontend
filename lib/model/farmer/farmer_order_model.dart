class FarmerOrderModel {
  const FarmerOrderModel({
    required this.id,
    required this.customerName,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
    this.customerEmail,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryMethod,
    this.paymentMethod,
    this.notes,
    this.items = const [],
  });

  final String id;
  final String customerName;
  final int itemCount;
  final double totalAmount;
  final String status;

  final String? customerEmail;
  final String? customerPhone;

  final String? deliveryAddress;
  final String? deliveryMethod;
  final String? paymentMethod;
  final String? notes;

  final List<FarmerOrderItemModel> items;

  factory FarmerOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    final rawItems = json['items'];

    return FarmerOrderModel(
      id: json['id']?.toString() ?? '',
      customerName:
          user['name']?.toString() ??
          json['customer_name']?.toString() ??
          'Customer',
      itemCount: rawItems is List
          ? rawItems.length
          : _toInt(json['item_count']),
      totalAmount:
          _toDouble(json['total_amount']) ?? 0,
      status:
          json['status']?.toString() ?? 'pending',
      customerEmail: user['email']?.toString(),
      customerPhone: user['phone']?.toString(),
      deliveryAddress:
          json['delivery_address']?.toString(),
      deliveryMethod:
          json['delivery_method']?.toString(),
      paymentMethod:
          json['payment_method']?.toString(),
      notes: json['notes']?.toString(),
      items: rawItems is List
          ? rawItems
              .map(
                (item) =>
                    FarmerOrderItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class FarmerOrderItemModel {
  const FarmerOrderItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    this.unit,
    this.farmId,
  });

  final String id;
  final String productName;
  final double quantity;
  final double price;
  final String? unit;
  final String? farmId;

  factory FarmerOrderItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(
            json['product'],
          )
        : <String, dynamic>{};

    return FarmerOrderItemModel(
      id: json['id']?.toString() ?? '',
      productName:
          product['name']?.toString() ??
          json['product_name']?.toString() ??
          'Product',
      quantity:
          _toDouble(json['quantity']) ?? 0,
      price:
          _toDouble(json['price']) ?? 0,
      unit: product['unit']?.toString(),
      farmId: product['farm_id']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}