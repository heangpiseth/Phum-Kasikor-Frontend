class InventoryCategoryModel {
  const InventoryCategoryModel({
    required this.id,
    required this.name,
    this.icon,
  });

  final String id;
  final String name;
  final String? icon;

  factory InventoryCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryCategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}