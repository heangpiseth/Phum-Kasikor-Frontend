class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
  });
  final String productId, productName;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  double get total => unitPrice * quantity;
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    quantity: json['quantity'] as int,
    imageUrl: json['imageUrl'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };
}