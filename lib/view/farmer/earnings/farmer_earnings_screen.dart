import 'package:flutter/material.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerEarningsScreen extends StatelessWidget {
  const FarmerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        elevation: 0,
        title: Text(
          'Earnings',
          style: FarmerDesign.heading2,
        ),
      ),
      body: Center(
        child: Text(
          'Earnings screen coming soon',
          style: FarmerDesign.body,
        ),
      ),
    );
  }
}