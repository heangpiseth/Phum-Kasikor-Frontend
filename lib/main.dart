import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import 'package:phum_kasikors/core/routes/app_pages.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phum Kasikor',
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}