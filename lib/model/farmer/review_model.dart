class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.farmId,
    required this.customerId,
    required this.rating,
    required this.createdAt,
    this.comment = '',
    this.customerName,
    this.customerImageUrl,
  });
  final String id, farmId, customerId, comment;
  final double rating;
  final DateTime createdAt;
  final String? customerName, customerImageUrl;
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String,
    farmId: json['farmId'] as String,
    customerId: json['customerId'] as String,
    rating: (json['rating'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    comment: json['comment'] as String? ?? '',
    customerName: json['customerName'] as String?,
    customerImageUrl: json['customerImageUrl'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'customerId': customerId,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    'comment': comment,
    'customerName': customerName,
    'customerImageUrl': customerImageUrl,
  };
}