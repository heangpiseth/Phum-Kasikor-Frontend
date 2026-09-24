class UserModel {
  final String name;
  final String avatarUrl;
  final String location;
  final int cartCount;
  final bool hasNotification;

  UserModel({
    required this.name,
    required this.avatarUrl,
    required this.location,
    required this.cartCount,
    required this.hasNotification,
  });
}

// ============================================================
// FARM MODEL
// ============================================================

class FarmModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final double distanceKm;

  FarmModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.distanceKm,
  });
}

// ============================================================
// NEARBY FARM MODEL
// ============================================================

class NearbyFarmModel {
  final String id;
  final String name;
  final String imageUrl;
  final double distanceKm;
  final String area;
  final int liveProducts;
  final double rating;

  NearbyFarmModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.distanceKm,
    required this.area,
    required this.liveProducts,
    required this.rating,
  });
}