import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';

class ProductResponse {
  final int currentPage;
  final List<ProductModel> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ProductResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List? ?? [])
          .map((e) => PaginationLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 20,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: json['page'],
      active: json['active'] ?? false,
    );
  }
}

class ProductModel {
  final int id;
  final int farmId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double quantityAvailable;
  final String? harvestDate;
  final String? farmingMethod;
  final bool isActive;
  final FarmModel? farm;
  final CategoryModel? category;
  final List<ProductImageModel> images;

  ProductModel({
    required this.id,
    required this.farmId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantityAvailable,
    this.harvestDate,
    this.farmingMethod,
    required this.isActive,
    this.farm,
    this.category,
    required this.images,
  });

  String get imageUrl {
  if (images.isEmpty) {
    return '';
  }

  // Find the first image that is actually stored permanently.
  final validImage = images.firstWhere(
    (image) {
      final path = image.image?.trim();

      if (path == null || path.isEmpty) {
        return false;
      }

      // Accept full URLs.
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return true;
      }

      // Ignore the old Windows temporary PHP files.
      if (path.contains(r'\Temp\') ||
          path.startsWith(r'C:\') ||
          path.startsWith('/tmp/')) {
        return false;
      }

      return true;
    },
    orElse: () => ProductImageModel(id: 0, image: null),
  );

  final image = validImage.image?.trim();

  if (image == null || image.isEmpty) {
    return '';
  }

  if (image.startsWith('http://') || image.startsWith('https://')) {
    return image;
  }

  return 'http://10.0.2.2:8000/storage/$image';
}

  String get farmName => farm?.farmName ?? '';

  String get priceLocal => '\$${(price * 4000).toStringAsFixed(0)}៛';

  double get rating => 4.5;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      farmId: json['farm_id'],
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      unit: json['unit'] ?? '',
      quantityAvailable:
          double.tryParse(json['quantity_available'].toString()) ?? 0,
      harvestDate: json['harvest_date'],
      farmingMethod: json['farming_method'],
      isActive: json['is_active'] ?? false,
      farm: json['farm'] != null ? FarmModel.fromJson(json['farm']) : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      images:
          (json['images'] as List?)
              ?.map((e) => ProductImageModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

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

  ProductImageModel({required this.id, this.image});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(id: json['id'], image: json['image']);
  }
}
