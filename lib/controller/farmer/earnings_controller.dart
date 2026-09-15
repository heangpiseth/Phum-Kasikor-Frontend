import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/earnings_model.dart';

class EarningsController extends GetxController {
  final earnings = EarningsModel(
    totalEarnings: 1240.00,
    growth: 15.4,
    ordersCompleted: 45,
    avgOrderValue: 27.55,
    pendingPayout: 340.00,

    weeklyIncome: [
      45,
      75,
      110,
      60,
    ],

    transactions: [
      TransactionModel(
        title: "Order Payout #ORD-2024-001",
        date: "Today, 2:30 PM",
        amount: 64.50,
        isIncome: true,
      ),

      TransactionModel(
        title: "Withdrawn to ABA Account",
        date: "Oct 20, 2024",
        amount: 450.00,
        isIncome: false,
      ),

      TransactionModel(
        title: "Order Payout #ORD-2024-012",
        date: "Oct 18, 2024",
        amount: 35.00,
        isIncome: true,
      ),
    ],
  ).obs;

  final selectedPeriod = 2.obs;

  void changePeriod(int index) {
    selectedPeriod.value = index;
  }

  void withdraw() {
    Get.snackbar(
      "Withdraw",
      "Withdrawal request submitted",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}