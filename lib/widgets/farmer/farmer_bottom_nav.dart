import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/earnings_controller.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/view/farmer/Farm/farmer_my_farm.dart';
import 'package:phum_kasikors/view/farmer/earning/farmer_earnings_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_home_screen.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_order_screen.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_profile_screen.dart';
import 'package:phum_kasikors/widgets/ai_assistant/ai_assistant_floating_button.dart';


class FarmerBottomNav extends StatefulWidget {
  const FarmerBottomNav({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<FarmerBottomNav> createState() => _FarmerBottomNavState();
}

class _FarmerBottomNavState extends State<FarmerBottomNav> {
  late int _selectedIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex.clamp(0, 4);

    // Register FarmerController
    if (!Get.isRegistered<FarmerController>()) {
      Get.put(
        FarmerController(),
        permanent: true,
      );
    }

    // Register EarningsController
    if (!Get.isRegistered<EarningsController>()) {
      Get.put(
        EarningsController(),
        permanent: true,
      );
    }

    // Profile can also be opened as a tab without visiting the app root.
    if (!Get.isRegistered<FarmerProfileController>()) {
      Get.put(
        FarmerProfileController(),
        permanent: true,
      );
    }

    // Main Farmer pages
    _pages = [
      const FarmerHomeScreen(),
      const FarmerMyFarmScreen(),
      const FarmerOrdersScreen(),
      EarningsScreen(),
      const FarmerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: const AiAssistantFloatingButton(isFarmer: true),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture),
            label: 'Farm',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
