import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// CUSTOMER CONTROLLERS
// ============================================================

import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_checkout_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_payment_controller.dart';

// ============================================================
// AUTH
// ============================================================

import 'package:phum_kasikors/view/Auth/splash_screen.dart';
import 'package:phum_kasikors/view/Auth/onboarding_screen.dart';
import 'package:phum_kasikors/view/Auth/login_screen.dart';
import 'package:phum_kasikors/view/Auth/sigup_screen.dart';
import 'package:phum_kasikors/view/Auth/otp_screen.dart';
import 'package:phum_kasikors/view/Auth/choose_role_screen.dart';
import 'package:phum_kasikors/view/Auth/profile_setup_screen.dart';
import 'package:phum_kasikors/view/Auth/location_setup_screen.dart';

// ============================================================
// CUSTOMER
// ============================================================

import 'package:phum_kasikors/view/costumer/costumer_home_screen.dart';
import 'package:phum_kasikors/view/costumer/cart/costumer_cart_screen.dart';
import 'package:phum_kasikors/view/costumer/checkout/costumer_checkout_screen.dart';
import 'package:phum_kasikors/view/costumer/checkout/costumer_payment_screen.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_map_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_product_screen.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_order_success_screen.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_order_tracking_view.dart';
import 'package:phum_kasikors/view/costumer/profile/costumer_profile_screen.dart';

// ============================================================
// FARMER
// ============================================================

import 'package:phum_kasikors/view/farmer/farmer_home_screen.dart';
import 'package:phum_kasikors/view/farmer/Farm/farmer_farm_profile.dart';
import 'package:phum_kasikors/view/farmer/earning/farmer_earnings_screen.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_order_detil_screen.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_order_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_add_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_add_product_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_crop_deteil_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_product_preview_screen.dart';
import 'package:phum_kasikors/view/farmer/product/farmer_product_screen.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_profile_screen.dart';

// ============================================================
// ROUTES
// ============================================================

import '../routes/app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> routes = [

    // ==========================================================
    // AUTH
    // ==========================================================

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => const SigupScreen(),
    ),

    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const ChooseRoleScreen(),
    ),

    GetPage(
      name: AppRoutes.verification,
      page: () => const OtpScreen(),
    ),

    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
    ),

    GetPage(
      name: AppRoutes.locationSetup,
      page: () => const LocationSetupScreen(),
    ),

    // ==========================================================
    // CUSTOMER HOME
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerHomescreen,
      page: () => const CostumerHomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.put<HomeController>(
            HomeController(),
          );
        }

        if (!Get.isRegistered<CartController>()) {
          Get.put<CartController>(
            CartController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER EXPLORE
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerExplorescreen,
      page: () => const Scaffold(
        body: Center(
          child: Text('Customer Explore'),
        ),
      ),
    ),

    // ==========================================================
    // CUSTOMER SEARCH
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerSearchFilterscreen,
      page: () => const Scaffold(
        body: Center(
          child: Text('Search & Filter'),
        ),
      ),
    ),

    // ==========================================================
    // CUSTOMER PRODUCT DETAIL
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerProductDetailscreen,
      page: () => const Scaffold(
        body: Center(
          child: Text('Product Details'),
        ),
      ),
    ),

    // ==========================================================
    // CUSTOMER FARM DETAIL
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerFarmDetailscreen,
      page: () => const Scaffold(
        body: Center(
          child: Text('Farm Details'),
        ),
      ),
    ),

    // ==========================================================
    // CUSTOMER FARM MAP
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerFarmMapscreen,
      page: () => const FarmMapView(),
    ),

    // ==========================================================
    // CUSTOMER FARM PRODUCTS
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerFarmProductsscreen,
      page: () => const FarmProductsScreen(),
    ),

    // ==========================================================
    // CUSTOMER PROFILE
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerProfilescreen,
      page: () => const CostumerProfileScreen(),
    ),

    // ==========================================================
    // CUSTOMER CART
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerCartscreen,
      page: () => const CartView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CartController>()) {
          Get.put<CartController>(
            CartController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER CHECKOUT
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerCheckoutscreen,
      page: () => const CheckoutView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CartController>()) {
          Get.put<CartController>(
            CartController(),
          );
        }

        if (!Get.isRegistered<CheckoutController>()) {
          Get.put<CheckoutController>(
            CheckoutController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER PAYMENT
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerPaymentscreen,
      page: () => const CostumerPaymentScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CartController>()) {
          Get.put<CartController>(
            CartController(),
          );
        }

        if (!Get.isRegistered<CheckoutController>()) {
          Get.put<CheckoutController>(
            CheckoutController(),
          );
        }

        if (!Get.isRegistered<PaymentController>()) {
          Get.put<PaymentController>(
            PaymentController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER ORDER SUCCESS
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerOrderSuccessscreen,
      page: () => const OrderSuccessView(),
    ),

    // ==========================================================
    // CUSTOMER ORDER TRACKING
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerOrderTrackingscreen,
      page: () => const OrderTrackingView(),
    ),

    // ==========================================================
    // FARMER HOME
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerHome,
      page: () => const FarmerHomeScreen(),
    ),

    // ==========================================================
    // FARMER PRODUCTS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerProducts,
      page: () => const FarmerProductsScreen(),
    ),

    // ==========================================================
    // FARMER ADD PRODUCT
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerAddProduct,
      page: () => const FarmerAddProductScreen(),
    ),

    // ==========================================================
    // FARMER PRODUCT PREVIEW
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerProductPreview,
      page: () => const FarmerProductPreviewScreen(
        productId: '',
      ),
    ),

    // ==========================================================
    // FARMER CROPS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerCrops,
      page: () => const FarmerCropsScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerAddCrop,
      page: () => const FarmerAddCropScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerCropDetail,
      page: () => const FarmerCropDetailScreen(
        cropId: '',
      ),
    ),

    // ==========================================================
    // FARMER EARNINGS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerEarnings,
      page: () => EarningsScreen(),
    ),

    // ==========================================================
    // FARMER FARM
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerFarmProfile,
      page: () => const FarmerFarmProfile(),
    ),

    GetPage(
      name: AppRoutes.farmerMyFarm,
      page: () => const FarmerFarmProfile(),
    ),

    // ==========================================================
    // FARMER ORDERS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerOrders,
      page: () => const FarmerOrdersScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerOrderDetail,
      page: () => const FarmerOrderDetailScreen(
        orderId: '',
      ),
    ),

    // ==========================================================
    // FARMER PROFILE
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerProfile,
      page: () => const FarmerProfileScreen(),
    ),
  ];
}
