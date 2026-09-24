class ProductCategoryModel {
  const ProductCategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.parentId,
    this.children = const [],
  });

  final String id;
  final String name;
  final String? image;
  final String? parentId;
  final List<ProductCategoryModel> children;

  factory ProductCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductCategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      parentId: json['parent_id']?.toString(),
      children: _parseChildren(json['children']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parent_id': parentId,
      'children': children
          .map((category) => category.toJson())
          .toList(),
    };
  }

  static List<ProductCategoryModel> _parseChildren(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => ProductCategoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}