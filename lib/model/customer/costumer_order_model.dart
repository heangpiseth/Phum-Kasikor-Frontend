// order_model.dart

enum PaymentMethod { abaBank, wingMoney, bakongKhqr, creditCard, cashOnDelivery }

enum DeliveryMethod { standard, express }

enum OrderStatus { placed, paymentConfirmed, preparing, outForDelivery, delivered }

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromCartItem(dynamic cartItem) => OrderItem(
        productId: cartItem.product.id as String,
        productName: cartItem.product.name as String,
        quantity: cartItem.quantity as int,
        unitPrice: (cartItem.product.price as num).toDouble(),
      );
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.abaBank:
        return 'ABA Bank (Pay Direct)';
      case PaymentMethod.wingMoney:
        return 'Wing Money';
      case PaymentMethod.bakongKhqr:
        return 'Bakong (KHQR Direct)';
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.abaBank:
        return 'Direct payment to farm\'s ABA Account';
      case PaymentMethod.wingMoney:
        return 'Direct WING transfer';
      case PaymentMethod.bakongKhqr:
        return 'Scan KHQR of the farm';
      case PaymentMethod.creditCard:
        return 'Standard processing';
      case PaymentMethod.cashOnDelivery:
        return 'Pay cash at your doorstep';
    }
  }
}

class OrderModel {
  final String id; // e.g. ORD-2024-001
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

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.farmName,
    required this.farmerName,
    required this.farmerPhone,
    this.note = '',
    this.deliveryFee = 2.0,
    this.status = OrderStatus.placed,
  });

  double get subtotal => items.fold<double>(
        0,
        (sum, item) => sum + item.lineTotal,
      );
  double get total => subtotal + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class ReviewModel {
  final String reviewerName;
  final double rating;
  final String comment;

  const ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });
}
