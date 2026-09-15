class FarmModel {
  const FarmModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.address,
    this.description = '',
    this.imageUrl,
    this.rating = 0,
    this.reviewCount = 0,
  });
  final String id, farmerId, name, address, description;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
    id: json['id'] as String,
    farmerId: json['farmerId'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    description: json['description'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'farmerId': farmerId,
    'name': name,
    'address': address,
    'description': description,
    'imageUrl': imageUrl,
    'rating': rating,
    'reviewCount': reviewCount,
  };
}