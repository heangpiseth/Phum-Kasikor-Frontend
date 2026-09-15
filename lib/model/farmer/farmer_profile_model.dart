class FarmerProfileModel {
  final String name;
  final String role;
  final String image;
  final int products;
  final int orders;
  final double rating;

  FarmerProfileModel({
    required this.name,
    required this.role,
    required this.image,
    required this.products,
    required this.orders,
    required this.rating,
  });
}

class ProfileMenuModel {
  final String title;
  final String icon;

  ProfileMenuModel({
    required this.title,
    required this.icon,
  });
}