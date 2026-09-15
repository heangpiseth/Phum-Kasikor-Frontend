class FarmerModel {
  const FarmerModel({
    required this.userId,
    required this.farmId,
    this.bio = '',
    this.isVerified = false,
  });
  final String userId, farmId, bio;
  final bool isVerified;
  factory FarmerModel.fromJson(Map<String, dynamic> json) => FarmerModel(
    userId: json['userId'] as String,
    farmId: json['farmId'] as String,
    bio: json['bio'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
  );
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'farmId': farmId,
    'bio': bio,
    'isVerified': isVerified,
  };
}