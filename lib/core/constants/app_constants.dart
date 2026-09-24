class ApiConstants {
  // Android Emulator -> Laravel running on your PC
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify';
  static const String firebaseVerify = '/auth/firebase/verify';

  static const String profile = '/profile';
  static const String chooseRole = '/profile/choose-role';
  static const String setupProfile = '/profile/setup';
  static const String setupLocation = '/profile/location';

  // Customer
  static const String customerProducts = '/customer/products';
  static const String customerProductCategories =
      '/customer/products/categories';
  static const String customerCart = '/customer/cart';
  static const String customerOrders = '/customer/orders';

  // Farmer
  static const String farmerFarms = '/farmer/farms';
  static const String farmerOrders = '/farmer/orders';
}
