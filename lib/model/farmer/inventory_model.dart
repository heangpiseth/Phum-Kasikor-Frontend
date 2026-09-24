class InventoryModel {
  const InventoryModel({
    required this.id,
    required this.farmId,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.quantity,
    this.unit,
    this.minimumStock,
    this.status,
  });

  final String id;
  final String farmId;
  final String name;

  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;

  final double? quantity;
  final String? unit;
  final double? minimumStock;
  final String? status;

  factory InventoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final category = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'])
        : null;

    return InventoryModel(
      id: json['id'].toString(),
      farmId: json['farm_id'].toString(),
      name: json['name']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      categoryName: category?['name']?.toString(),
      categoryIcon: category?['icon']?.toString(),
      quantity: _toDouble(json['quantity']),
      unit: json['unit']?.toString(),
      minimumStock: _toDouble(json['minimum_stock']),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'category_id': categoryId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minimum_stock': minimumStock,
      'status': status,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  // ============================================================
  // STOCK HELPERS
  // ============================================================

  bool get isOutOfStock {
    return status == 'out_of_stock' ||
        (quantity != null && quantity! <= 0);
  }

  bool get isLowStock {
    if (status == 'low_stock') {
      return true;
    }

    if (quantity == null || minimumStock == null) {
      return false;
    }

    return quantity! > 0 && quantity! <= minimumStock!;
  }

  bool get isInStock {
    if (status == 'in_stock') {
      return true;
    }

    return !isOutOfStock && !isLowStock;
  }

  String get displayStatus {
    if (isOutOfStock) {
      return 'Out of stock';
    }

    if (isLowStock) {
      return 'Low stock';
    }

    return 'In stock';
  }

  String get quantityLabel {
    final value = quantity ?? 0;

    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    if (unit == null || unit!.trim().isEmpty) {
      return formatted;
    }

    return '$formatted ${unit!}';
  }

  String get minimumStockLabel {
    final value = minimumStock ?? 0;

    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    if (unit == null || unit!.trim().isEmpty) {
      return formatted;
    }

    return '$formatted ${unit!}';
  }
}