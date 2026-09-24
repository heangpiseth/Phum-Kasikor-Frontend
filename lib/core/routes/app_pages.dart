import 'package:get/get.dart';

// ============================================================
// CUSTOMER CONTROLLERS
// ============================================================

import 'package:phum_kasikors/controller/costumer/customer_order_controller.dart';
import 'package:phum_kasikors/controller/farmer/watering_controller.dart';
import 'package:phum_kasikors/view/Auth/wecome_screen.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_orders_screen.dart'
    as customer_orders;
import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_checkout_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_payment_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_explore_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_search_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_farm_detail_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_product_detail_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_profile_controller.dart';
import 'package:phum_kasikors/controller/costumer/farm_map_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_order_tracking_controller.dart';

// ============================================================
// AUTH VIEWS
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
// CUSTOMER VIEWS
// ============================================================

import 'package:phum_kasikors/view/costumer/cart/costumer_cart_screen.dart';
import 'package:phum_kasikors/view/costumer/checkout/costumer_checkout_screen.dart';
import 'package:phum_kasikors/view/costumer/checkout/costumer_payment_screen.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_map_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_explore_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_search_filter_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_detail_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_product_detail_view.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_farm_product_screen.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_order_success_screen.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_order_tracking_view.dart';
import 'package:phum_kasikors/view/costumer/profile/costumer_profile_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_farm_profile_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_navigation_screen.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_orders_screen.dart';
import 'package:phum_kasikors/widgets/costumer/costumer_buttom_nvb.dart';
import 'package:phum_kasikors/view/ai_assistant/ai_assistant_chat_screen.dart';

// ============================================================
// FARMER VIEWS
// ============================================================


import 'package:phum_kasikors/view/farmer/products/farmer_products_screen.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_add_product_screen.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_edit_product_screen.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_product_detail_screen.dart';

import 'package:phum_kasikors/view/farmer/inventory/farmer_inventory_screen.dart';


import 'package:phum_kasikors/view/farmer/farm/farmer_fields_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_add_edit_field_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_crops_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_add_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_crop_detail_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_watering_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_harvest_screen.dart';

import 'package:phum_kasikors/view/farmer/orders/farmer_order_detail_screen.dart';

import 'package:phum_kasikors/view/farmer/earnings/farmer_earnings_screen.dart';

import 'package:phum_kasikors/view/farmer/profile/farmer_profile_screen.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_edit_profile_screen.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_verification_screen.dart';

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

    GetPage(
      name: AppRoutes.locationSetup,
      page: () => const WelcomeScreen(),
    ),

    // ==========================================================
    // CUSTOMER HOME
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerHomescreen,
      page: () => MainNavView(),
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
      page: () => const ExploreView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ExploreController>()) {
          Get.put<ExploreController>(
            ExploreController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER SEARCH
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerSearchFilterscreen,
      page: () => const SearchView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SearchFilterController>()) {
          Get.put<SearchFilterController>(
            SearchFilterController(),
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
    // CUSTOMER PRODUCT DETAIL
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerProductDetailscreen,
      page: () => const CostumerProductDetailView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProductDetailController>()) {
          Get.put<ProductDetailController>(
            ProductDetailController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER FARM DETAIL
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerFarmDetailscreen,
      page: () => const CostumerFarmDetailView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<FarmDetailController>()) {
          Get.put<FarmDetailController>(
            FarmDetailController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER FARM MAP
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerFarmMapscreen,
      page: () => const FarmMapView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<FarmMapController>()) {
          Get.put<FarmMapController>(
            FarmMapController(),
          );
        }
      }),
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
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put<ProfileController>(
            ProfileController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER CART
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerCartscreen,
      page: () => const CustomerCartScreen(),
    ),

    // ==========================================================
    // CUSTOMER ORDERS
    // ==========================================================

    GetPage(
      name: '/costumer/orders',
      page: () => const customer_orders.CustomerOrdersScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerOrderController>()) {
          Get.put<CustomerOrderController>(
            CustomerOrderController(),
          );
        }
      }),
    ),

    // ==========================================================
    // CUSTOMER CHECKOUT
    // ==========================================================

    GetPage(
      name: AppRoutes.costumerCheckoutscreen,
      page: () => CheckoutView(),
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
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OrderTrackingController>()) {
          Get.put<OrderTrackingController>(
            OrderTrackingController(),
          );
        }
      }),
    ),

    // ==========================================================
    // AI ASSISTANT
    // ==========================================================

    GetPage(
      name: AppRoutes.aiAssistant,
      page: () => AiAssistantChatScreen(
        isFarmer: Get.arguments is bool
            ? Get.arguments as bool
            : false,
      ),
    ),

    // ==========================================================
    // FARMER HOME
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerHome,
      page: () => const FarmerNavigationScreen(),
    ),

    // ==========================================================
    // FARMER PRODUCTS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerProducts,
      page: () => const FarmerProductsScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerAddProduct,
      page: () => const FarmerAddProductScreen(
        farmId: '',
      ),
    ),

    GetPage(
      name: '/farmer/products/edit',
      page: () => const FarmerEditProductScreen(
        farmId: '',
        productId: '',
      ),
    ),

    GetPage(
      name: AppRoutes.farmerProductPreview,
      page: () {
        final args = Get.arguments;

        if (args is Map) {
          return FarmerProductDetailScreen(
            farmId: args['farmId']?.toString() ?? '',
            productId: args['productId']?.toString() ?? '',
          );
        }

        return const FarmerProductDetailScreen(
          farmId: '',
          productId: '',
        );
      },
    ),

    // ==========================================================
    // FARMER INVENTORY
    // ==========================================================

    GetPage(
  name: AppRoutes.farmerInventory,
  page: () {
    final args = Get.arguments;

    final farmId = args is String
        ? args
        : args is Map
            ? args['farmId']?.toString() ?? ''
            : '';

    return FarmerInventoryScreen(
      farmId: farmId,
    );
  },
),
//========================================================
    // FARMER FARM PROFILE
    // ==========================================================

    GetPage(
  name: AppRoutes.farmerFarmProfile,
  page: () => const FarmerFarmScreen(),
),
    // ==========================================================
    // FARMER FIELDS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerFields,
      page: () {
        final args = Get.arguments;

        final farmId = args is String
            ? args
            : args is Map
                ? args['farmId']?.toString() ?? ''
                : '';

        return FarmerFieldsScreen(
          farmId: farmId,
        );
      },
    ),

    GetPage(
      name: AppRoutes.farmerAddEditField,
      page: () {
        final args = Get.arguments;

        if (args is Map) {
          return FarmerAddEditFieldScreen(
            farmId: args['farmId']?.toString() ?? '',
            fieldId: args['fieldId']?.toString(),
          );
        }

        return FarmerAddEditFieldScreen(
          farmId: args is String ? args : '',
        );
      },
    ),

    // ==========================================================
    // FARMER CROPS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerCrops,
      page: () {
        final args = Get.arguments;

        final farmId = args is String
            ? args
            : args is Map
                ? args['farmId']?.toString() ?? ''
                : '';

        return FarmerCropsScreen(
          farmId: farmId,
        );
      },
    ),

    GetPage(
      name: AppRoutes.farmerAddCrop,
      page: () {
        final args = Get.arguments;

        final farmId = args is String
            ? args
            : args is Map
                ? args['farmId']?.toString() ?? ''
                : '';

        return FarmerAddCropScreen(
          farmId: farmId,
        );
      },
    ),

    GetPage(
      name: AppRoutes.farmerCropDetail,
      page: () {
        final args = Get.arguments;

        if (args is Map) {
          return FarmerCropDetailScreen(
            farmId: args['farmId']?.toString() ?? '',
            cropId: args['cropId']?.toString() ?? '',
          );
        }

        return const FarmerCropDetailScreen(
          farmId: '',
          cropId: '',
        );
      },
    ),

    // ==========================================================
    // FARMER WATERING
    // ==========================================================

  GetPage(
  name: AppRoutes.farmerWatering,
  page: () => FarmerWateringScreen(cropId: '',),
  binding: BindingsBuilder(() {
    if (!Get.isRegistered<WateringController>()) {
      Get.put<WateringController>(
        WateringController(),
      );
    }
  }),
), 

    // ==========================================================
    // FARMER HARVEST
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerHarvest,
      page: () {
        final args = Get.arguments;

        final farmId = args is String
            ? args
            : args is Map
                ? args['farmId']?.toString() ?? ''
                : '';

        return FarmerHarvestScreen(
          farmId: farmId,
        );
      },
    ),

    // ==========================================================
    // FARMER EARNINGS
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerEarnings,
      page: () => const FarmerEarningsScreen(),
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
      page: () {
        final args = Get.arguments;

        final orderId = args is String
            ? args
            : args is Map
                ? args['orderId']?.toString() ?? ''
                : '';

        return FarmerOrderDetailScreen(
          orderId: orderId,
        );
      },
    ),

    // ==========================================================
    // FARMER PROFILE
    // ==========================================================

    GetPage(
      name: AppRoutes.farmerProfile,
      page: () => const FarmerProfileScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerEditProfile,
      page: () => const FarmerEditProfileScreen(),
    ),

    GetPage(
      name: AppRoutes.farmerVerification,
      page: () => const FarmerVerificationScreen(),
    ),
  ];
}