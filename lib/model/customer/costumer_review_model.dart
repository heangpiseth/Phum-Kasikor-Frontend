class ReviewModel {
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  const ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.date = '',
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final dynamic user = json['user'];
    final String reviewerName = json['reviewer_name']?.toString() ??
        (user is Map ? user['name']?.toString() ?? '' : '');

    return ReviewModel(
      reviewerName: reviewerName,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }
}
