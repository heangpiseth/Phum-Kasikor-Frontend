// product_model.dart
enum ProductCategory { vegetables, fruits, rice, herbs, dairyEggs, processed, organic, specialty;

  toLowerCase() {} }

enum StockStatus { inStock, lowStock, outOfStock }

class ProductModel {
  final String id;
  final String name;
  final String nameLocal; // e.g. Khmer name shown in parentheses
  final String farmId;
  final String farmName;
  final String imageUrl;
  final double price;
  final String unit; // e.g. /kg, /bunch, /jar
  final double rating;
  final int reviewCount;
  final StockStatus stock;
  final ProductCategory category;
  final String origin;
  final String method;
  final String harvest;
  final String minOrder;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    this.nameLocal = '',
    required this.farmId,
    required this.farmName,
    required this.imageUrl,
    required this.price,
    required this.unit,
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = StockStatus.inStock,
    required this.category,
    this.origin = '',
    this.method = '',
    this.harvest = '',
    this.minOrder = '',
    this.description = '',
  });

  String get priceLabel => '\$${price.toStringAsFixed(2)}$unit';
}