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
import 'package:phum_kasikors/widgets/ai_assistant/ai_assistant_floating_button.dart';

/// Bottom-nav shell hosting Home / Explore / Orders / Cart / Profile.
class MainNavView extends GetView<NavController> {
  MainNavView({super.key});

  final List<Widget> _pages = [
    CostumerHomeScreen(),
    const ExploreView(),
    const OrdersListView(),
    const CustomerCartScreen(),
    const CostumerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
      ),
      floatingActionButton: const AiAssistantFloatingButton(isFarmer: false),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cart.totalItems > 0,
                label: Text('${cart.totalItems}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
