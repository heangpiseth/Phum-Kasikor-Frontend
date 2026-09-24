class CategoryModel {
  final int id;
  final String name;
  final String? image;
  final int? parentId;

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      parentId: json['parent_id'],
    );
  }
}

class ProductImageModel {
  final int id;
  final String? image;

  ProductImageModel({
    required this.id,
    this.image,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'],
      image: json['image'],
    );
  }
}