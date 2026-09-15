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
}