class ProductModel {
  const ProductModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.price,
    required this.unit,
    required this.stock,
    this.categoryId,
    this.description = '',
    this.imageUrl,
    this.isAvailable = true,
  });
  final String id, farmId, name, unit, description;
  final String? categoryId, imageUrl;
  final double price;
  final int stock;
  final bool isAvailable;
  bool get isInStock => isAvailable && stock > 0;
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    farmId: json['farmId'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    unit: json['unit'] as String,
    stock: json['stock'] as int,
    categoryId: json['categoryId'] as String?,
    description: json['description'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    isAvailable: json['isAvailable'] as bool? ?? true,
  );

  Null get priceLabel => null;

  Null get farmName => null;
  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'name': name,
    'price': price,
    'unit': unit,
    'stock': stock,
    'categoryId': categoryId,
    'description': description,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
  };
}
