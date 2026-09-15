import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_cart_controller.dart';
import 'package:phum_kasikors/controller/costumer/navigation/costumer_nav_controller.dart';
import 'package:phum_kasikors/view/costumer/cart/costumer_cart_screen.dart';
import 'package:phum_kasikors/view/costumer/costumer_home_screen.dart';
import 'package:phum_kasikors/view/costumer/marketplace/costumer_explore_view.dart';
import 'package:phum_kasikors/view/costumer/orders/costumer_order_list_screen.dart';
import 'package:phum_kasikors/view/costumer/profile/costumer_profile_screen.dart';


/// The bottom-nav shell that hosts Home / Explore / Orders / Cart / Profile,
/// matching the tab bar shown across every customer screen in the designs.
class MainNavView extends GetView<NavController> {
  const MainNavView({super.key});

  static const _pages = [
    CostumerHomeScreen(),
    ExploreView(),
    OrdersListView(),
    CartView(),
    CostumerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              BottomNavigationBarItem(
                icon: Obx(() => Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    )),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ));
  }
}