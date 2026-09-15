import 'package:flutter/material.dart';

/// Represents the signed-in customer shown on the profile screen.
class CustomerProfile {
  final String name;
  final String memberSince;
  final String location;
  final String avatarUrl;
  final bool verified;
  final int ordersCount;
  final int favoritesCount;
  final int reviewsCount;

  const CustomerProfile({
    required this.name,
    required this.memberSince,
    required this.location,
    required this.avatarUrl,
    this.verified = false,
    this.ordersCount = 0,
    this.favoritesCount = 0,
    this.reviewsCount = 0,
  });

  /// Demo/default profile used until real data is loaded.
  factory CustomerProfile.demo() => const CustomerProfile(
        name: 'Channa Sok',
        memberSince: 'Member since July 2024',
        location: 'Phnom Penh, Cambodia',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&h=120&fit=crop&crop=faces',
        verified: true,
        ordersCount: 12,
        favoritesCount: 8,
        reviewsCount: 5,
      );

  CustomerProfile copyWith({
    String? name,
    String? memberSince,
    String? location,
    String? avatarUrl,
    bool? verified,
    int? ordersCount,
    int? favoritesCount,
    int? reviewsCount,
  }) {
    return CustomerProfile(
      name: name ?? this.name,
      memberSince: memberSince ?? this.memberSince,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      verified: verified ?? this.verified,
      ordersCount: ordersCount ?? this.ordersCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}

/// A single row in the profile menu list.
class ProfileMenuItem {
  final IconData icon;
  final String label;
  final int? badge;
  final bool highlight;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.highlight = false,
    this.onTap,
  });
}

/// A single tab in the bottom navigation bar.
class NavTab {
  final IconData icon;
  final String label;

  const NavTab({required this.icon, required this.label});
}