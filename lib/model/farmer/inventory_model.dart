class InventoryModel {
  final String id;
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double? price;
  final DateTime? expiryDate;
  final String? notes;

  InventoryModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.price,
    this.expiryDate,
    this.notes,
  });

  InventoryModel copyWith({
    String? id,
    String? productName,
    String? category,
    double? quantity,
    String? unit,
    double? price,
    DateTime? expiryDate,
    String? notes,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_name': productName,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'expiry_date': expiryDate?.toIso8601String(),
    'notes': notes,
  };

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel(
    id: json['id'] as String? ?? '',
    productName: json['product_name'] as String? ?? '',
    category: json['category'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
    expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'] as String) : null,
    notes: json['notes'] as String?,
  );
}