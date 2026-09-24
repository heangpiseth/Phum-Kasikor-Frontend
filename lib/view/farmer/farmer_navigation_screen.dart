import 'package:flutter/material.dart';

import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/farmer_home_screen.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_products_screen.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_orders_screen.dart';
import 'package:phum_kasikors/view/farmer/ai/farmer_ai_chat_screen.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_profile_screen.dart';
import 'package:phum_kasikors/widgets/farmer/farmer_bottom_nav_bar.dart';

class FarmerNavigationScreen extends StatefulWidget {
  const FarmerNavigationScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerNavigationScreen> createState() =>
      _FarmerNavigationScreenState();
}

class _FarmerNavigationScreenState
    extends State<FarmerNavigationScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 1. HOME
          const FarmerHomeScreen(),

          // 2. PRODUCTS
          FarmerProductsScreen(
            farmId: widget.farmId,
          ),

          // 3. ORDERS
          FarmerOrdersScreen(),

          // 4. AI CHAT
          FarmerAiChatScreen(),

          // 5. PROFILE
          const FarmerProfileScreen(),
        ],
      ),

      bottomNavigationBar: FarmerBottomNavigationBar(
        currentIndex: _currentIndex,
        onChanged: _changeTab,
      ),
    );
  }
}