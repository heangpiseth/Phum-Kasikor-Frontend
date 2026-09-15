class OrderModel {
  final String orderId;
  final String productName;
  final String sellerName;

  final String customerName;
  final String phone;
  final String address;

  final List<OrderItemModel> items;

  final double subtotal;
  final double deliveryFee;
  final double total;

  final String paymentMethod;
  final bool paymentVerified;

  int fulfillmentStage;

  OrderModel({
    required this.orderId,
    required this.productName,
    required this.sellerName,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentVerified,
    this.fulfillmentStage = 2,
  });
}

class OrderItemModel {
  final String name;
  final String khmerName;
  final String quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.khmerName,
    required this.quantity,
    required this.price,
  });
}