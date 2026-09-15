import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';


/// Acts as a lightweight "repository" — swap the bodies of these methods
/// for real API/Firestore calls later without touching any controller.
class MockDataService extends GetxService {
  static MockDataService get to => Get.find();

  final List<FarmModel> _farms = [
    const FarmModel(
      id: 'farm_sokha',
      name: "Sokha's Organic Farm",
      province: 'Kandal Province',
      imageUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800',
      rating: 4.8,
      reviewCount: 156,
      followerCount: 89,
      distanceKm: 2.3,
      productCount: 24,
      ownerName: 'Sokha Vann',
      latitude: 11.4867,
      longitude: 104.9282,
      
    ),
    const FarmModel(
      id: 'farm_battambang',
      name: 'Battambang Sweet Farm',
      province: 'Battambang',
      imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
      rating: 4.9,
      reviewCount: 98,
      distanceKm: 2.3,
    ),
    const FarmModel(
      id: 'farm_prekleap',
      name: 'Prek Leap Eco Farm',
      province: 'Kandal Border',
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
      rating: 4.7,
      reviewCount: 61,
      distanceKm: 1.5,
      productCount: 18,
    ),
  ];

  late final List<ProductModel> _products = [
    ProductModel(
      id: 'p_jasmine_rice',
      name: 'Fresh Jasmine Rice',
      nameLocal: 'អង្ករផ្កាម្លិះ',
      farmId: 'farm_sokha',
      farmName: "Sokha's Organic Farm",
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800',
      price: 2.50,
      unit: '/kg',
      rating: 4.8,
      reviewCount: 24,
      stock: StockStatus.inStock,
      category: ProductCategory.rice,
      origin: 'Kandal Province',
      method: '100% Organic',
      harvest: 'Jul 2024',
      minOrder: '1 kg',
      description:
          'Premium organic Jasmine Rice harvested straight from fertile floodplains of Kandal. '
          'Carefully grown using ancestor organic pesticide-free methods, high fragrance and '
          'beautifully soft texture when cooked.',
    ),
    ProductModel(
      id: 'p_morning_glory',
      name: 'Organic Morning Glory',
      farmId: 'farm_sokha',
      farmName: "Sokha's Organic Farm",
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=800',
      price: 1.00,
      unit: '/bunch',
      rating: 4.6,
      reviewCount: 14,
      stock: StockStatus.lowStock,
      category: ProductCategory.vegetables,
      origin: 'Kandal Province',
      method: '100% Organic',
      minOrder: '1 bunch',
      description: 'Crisp organic morning glory, picked fresh each morning.',
    ),
    ProductModel(
      id: 'p_water_spinach',
      name: 'Water Spinach',
      farmId: 'farm_prekleap',
      farmName: 'Prek Leap Eco Farm',
      imageUrl: 'https://images.unsplash.com/photo-1622206151226-18ca2c9d680d?w=800',
      price: 0.90,
      unit: '/bunch',
      rating: 4.5,
      reviewCount: 9,
      stock: StockStatus.inStock,
      category: ProductCategory.vegetables,
    ),
    ProductModel(
      id: 'p_dragon_fruit',
      name: 'Organic Dragon Fruit',
      farmId: 'farm_sokha',
      farmName: "Sokha's Organic Farm",
      imageUrl: 'https://images.unsplash.com/photo-1527325678964-54921661f888?w=800',
      price: 3.00,
      unit: '/kg',
      rating: 4.7,
      reviewCount: 20,
      stock: StockStatus.inStock,
      category: ProductCategory.fruits,
    ),
    ProductModel(
      id: 'p_palm_sugar',
      name: 'Pure Palm Sugar',
      farmId: 'farm_sokha',
      farmName: "Sokha's Organic Farm",
      imageUrl: 'https://images.unsplash.com/photo-1610725664285-7c57e6eab473?w=800',
      price: 5.00,
      unit: '/jar',
      rating: 4.9,
      reviewCount: 31,
      stock: StockStatus.inStock,
      category: ProductCategory.processed,
    ),
    ProductModel(
      id: 'p_kampot_pepper',
      name: 'Kampot Black Pepper',
      farmId: 'farm_sokha',
      farmName: "Sokha's Organic Farm",
      imageUrl: 'https://images.unsplash.com/photo-1599909533144-534764537e91?w=800',
      price: 8.50,
      unit: '/jar',
      rating: 4.9,
      reviewCount: 14000,
      stock: StockStatus.inStock,
      category: ProductCategory.specialty,
    ),
  ];

  final List<ReviewModel> _reviews = const [
    ReviewModel(
      reviewerName: 'Sopheak N.',
      rating: 5,
      comment:
          'The fragrance is incredibly fresh, soft texture absolutely perfect when cooked! Will buy weekly.',
    ),
    ReviewModel(
      reviewerName: 'Kanha S.',
      rating: 4,
      comment:
          'Very authentic Phka Rumduol rice. Extremely clean and fast delivery from Kandal.',
    ),
  ];

  List<FarmModel> get farms => _farms;
  List<ProductModel> get products => _products;
  List<ReviewModel> get reviews => _reviews;

  FarmModel farmById(String id) => _farms.firstWhere((f) => f.id == id);

  List<ProductModel> productsByFarm(String farmId) =>
      _products.where((p) => p.farmId == farmId).toList();

  List<ProductModel> get featuredToday => _products.take(4).toList();

  List<ProductModel> get popularProducts =>
      _products.where((p) => p.category == ProductCategory.processed).toList();

  List<ProductModel> search(String query, {ProductCategory? category}) {
    return _products.where((p) {
      final matchesQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}