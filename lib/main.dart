import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:phum_kasikors/core/service/farmer/notifications/notification_service.dart';

import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import 'package:phum_kasikors/controller/costumer/customer_order_controller.dart';
import 'package:phum_kasikors/controller/costumer/navigation/costumer_nav_controller.dart';

import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/controller/farmer/farmer_order_controller.dart';
import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/controller/farmer/inventory_category_controller.dart';
import 'package:phum_kasikors/controller/farmer/inventory_controller.dart';
import 'package:phum_kasikors/controller/farmer/product_category_controller.dart';
import 'package:phum_kasikors/controller/farmer/product_controller.dart';
import 'package:phum_kasikors/controller/farmer/order_controller.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';
import 'package:phum_kasikors/controller/farmer/harvest_controller.dart';

import 'package:phum_kasikors/core/routes/app_pages.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/widgets/costumer/costumer_buttom_nvb.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await NotificationService.initialize();
  await NotificationService.requestPermission();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(NavController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  Get.put<FarmController>(FarmController(), permanent: true);

  Get.put<CustomerProductRepository>(
    CustomerProductRepository(),
    permanent: true,
  );

  Get.lazyPut<MainNavView>(() => MainNavView());

  Get.lazyPut<FieldController>(() => FieldController());

  Get.lazyPut<CropController>(() => CropController());

  Get.lazyPut<HarvestController>(() => HarvestController());

  Get.lazyPut<CustomerOrderController>(() => CustomerOrderController());

  Get.lazyPut<FarmerProductController>(() => FarmerProductController());

  Get.lazyPut<ProductCategoryController>(() => ProductCategoryController());

  Get.lazyPut<FarmerOrderController>(() => FarmerOrderController());

  Get.lazyPut<FarmerProfileController>(() => FarmerProfileController());

  Get.lazyPut<InventoryController>(() => InventoryController(), fenix: true);

  Get.lazyPut<InventoryCategoryController>(
    () => InventoryCategoryController(),
    fenix: true,
  );

  Get.lazyPut<OrderController>(() => OrderController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phum Kasikor',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),

        scaffoldBackgroundColor: const Color(0xFFF8FAF8),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      initialRoute: AppRoutes.login,

      getPages: AppPages.routes,
    );
  }
}