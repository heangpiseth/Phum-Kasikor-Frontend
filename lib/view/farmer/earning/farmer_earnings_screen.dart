import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/earnings_controller.dart';
import 'package:phum_kasikors/widgets/farmer/farmer_bottom_nav.dart';

class EarningsScreen extends StatelessWidget {
  EarningsScreen({super.key});

  final EarningsController controller = Get.put(EarningsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Earnings Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 15),

              _periodTabs(),

              const SizedBox(height: 16),

              _earningsCard(),

              const SizedBox(height: 16),

              _weeklyIncomeCard(),

              const SizedBox(height: 16),

              _summaryCards(),

              const SizedBox(height: 25),

              const Text(
                "RECENT TRANSACTIONS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff607D8B),
                ),
              ),

              const SizedBox(height: 12),

              _transactions(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: FarmerBottomNav(),
    );
  }

  Widget _periodTabs() {
    final periods = ["Today", "Week", "Month", "Year"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(
        () => Row(
          children: List.generate(periods.length, (index) {
            final selected = controller.selectedPeriod.value == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.changePeriod(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xff2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      periods[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xff607D8B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _earningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff2E7D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Monthly Earnings",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),

              Obx(
                () => Text(
                  "↑ +${controller.earnings.value.growth}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(
            () => Text(
              "\$${controller.earnings.value.totalEarnings.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ABA Account: **** 4523",
                style: TextStyle(color: Colors.white70),
              ),

              ElevatedButton(
                onPressed: controller.withdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff2E7D32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Withdraw",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weeklyIncomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Income Flow (USD)",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xff607D8B),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 110,
            child: Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  controller.earnings.value.weeklyIncome.length,
                  (index) {
                    final value = controller.earnings.value.weeklyIncome[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: value,
                          decoration: BoxDecoration(
                            color: index == 2
                                ? const Color(0xff2E7D32)
                                : const Color(0xffE4F3E7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "W${index + 1}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff607D8B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _summaryItem(
              title: "Orders Completed",
              value: "${controller.earnings.value.ordersCompleted}",
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _summaryItem(
              title: "Avg Order Val",
              value:
                  "\$${controller.earnings.value.avgOrderValue.toStringAsFixed(2)}",
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _summaryItem(
              title: "Pending Payout",
              value: "\$${controller.earnings.value.pendingPayout.toInt()}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({required String title, required String value}) {
    return Container(
      height: 75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xff78909C)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff263238),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactions() {
    return Obx(
      () => Column(
        children: controller.earnings.value.transactions.map((transaction) {
          final bool isIncome = transaction.isIncome;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff263238),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff90A4AE),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  isIncome
                      ? "+\$${transaction.amount.toStringAsFixed(2)}"
                      : "-\$${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isIncome
                        ? const Color(0xff2E7D32)
                        : const Color(0xff263238),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  
}

