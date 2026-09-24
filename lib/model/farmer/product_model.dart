class ProductModel {
  const ProductModel({
    required this.id,
    required this.farmId,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantityAvailable,
    this.description,
    this.harvestDate,
    this.farmingMethod,
    this.isActive = true,
    this.images = const [],
  });

  final String id;
  final String farmId;
  final String categoryId;
  final String name;

  final double price;
  final String unit;
  final double quantityAvailable;

  final String? description;
  final DateTime? harvestDate;
  final String? farmingMethod;

  final bool isActive;

  final List<ProductImageModel> images;

  int get stock => quantityAvailable.toInt();

  bool get isInStock => quantityAvailable > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _string(json['id']),
      farmId: _string(json['farm_id']),
      categoryId: _string(json['category_id']),
      name: _string(json['name']),
      price: _toDouble(json['price']),
      unit: _string(
        json['unit'],
        fallback: 'kg',
      ),
      quantityAvailable: _toDouble(
        json['quantity_available'],
      ),
      description: json['description']?.toString(),
      harvestDate: _parseDate(json['harvest_date']),
      farmingMethod: json['farming_method']?.toString(),
      isActive: _parseIsActive(json),
      images: _parseImages(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity_available': quantityAvailable,
      'harvest_date':
          harvestDate == null
              ? null
              : _formatDate(harvestDate!),
      'farming_method': farmingMethod,
      'is_active': isActive,
      'images':
          images.map((image) => image.toJson()).toList(),
    };
  }

  static String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    if (result.isEmpty || result == 'null') {
      return fallback;
    }

    return result;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _parseIsActive(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('is_active')) {
      return true;
    }

    final value = json['is_active'];

    if (value == true || value == 1) {
      return true;
    }

    if (value is String) {
      return value.toLowerCase() == 'true' ||
          value == '1';
    }

    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static List<ProductImageModel> _parseImages(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => ProductImageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static String _formatDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}

class ProductImageModel {
  const ProductImageModel({
    required this.id,
    required this.image,
    this.isPrimary = false,
  });

  final String id;
  final String image;
  final bool isPrimary;

  factory ProductImageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductImageModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isPrimary:
          json['is_primary'] == true ||
          json['is_primary'] == 1 ||
          json['is_primary']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'is_primary': isPrimary,
    };
  }
}