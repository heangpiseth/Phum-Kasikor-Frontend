class FarmModel {
  final String id;
  final String name;
  final String province;
  final String imageUrl;
  final double rating;
  final String description;
  final int reviewCount;
  final int followerCount;
  final double distanceKm;
  final bool isVerifiedOrganic;
  final bool isOpen;
  final int productCount;
  final String ownerName;
  final String ownerPhone;
  final String ownerAvatarUrl;
  final double latitude;
  final double longitude;
  final String about;
  const FarmModel({
    required this.id,
    required this.name,
    required this.province,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    this.followerCount = 0,
    this.distanceKm = 0,
    this.isVerifiedOrganic = true,
    this.isOpen = true,
    this.productCount = 0,
    this.ownerName = '',
    this.ownerPhone = '',
    this.ownerAvatarUrl = '',
    this.latitude = 0,
    this.longitude = 0,
    this.about = '',
  });

}