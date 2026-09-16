import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import 'package:phum_kasikors/controller/ai_assistant_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_home_controller.dart';
import 'package:phum_kasikors/controller/costumer/navigation/costumer_nav_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_explore_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_orders_list_controller.dart';
import 'package:phum_kasikors/controller/costumer/costumer_profile_controller.dart';
import 'package:phum_kasikors/controller/farmer/earnings_controller.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/core/routes/app_pages.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';

import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Services
  Get.put(
    MockDataService(),
    permanent: true,
  );

  // Controllers
  Get.put(
    AuthController(),
    permanent: true,
  );

  Get.put(AiAssistantController(), permanent: true);

  Get.put(
    CartController(),
    permanent: true,
  );

  Get.put(
    HomeController(),
    permanent: true,
  );

  Get.put(
    NavController(),
    permanent: true,
  );

  Get.put(ExploreController(), permanent: true);
  Get.put(OrdersListController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  // Farmer screens can be opened directly from named routes, so their shared
  // controllers must be available before a screen calls Get.find().
  Get.put(FarmerController(), permanent: true);
  Get.put(EarningsController(), permanent: true);
  Get.put(FarmerProfileController(), permanent: true);

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

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF8FAF8),

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

      initialRoute: AppRoutes.splash,

      getPages: AppPages.routes,
    );
  }
}
