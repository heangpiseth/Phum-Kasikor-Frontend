class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.productCount = 0,
  });
  final String id, name;
  final String? imageUrl;
  final int productCount;
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    productCount: json['productCount'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'productCount': productCount,
  };
}