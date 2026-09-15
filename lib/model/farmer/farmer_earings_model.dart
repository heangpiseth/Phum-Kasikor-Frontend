class EarningSummaryModel {
  final double totalEarnings;
  final double growth;
  final String accountNumber;
  final int ordersCompleted;
  final double averageOrderValue;
  final double pendingPayout;

  const EarningSummaryModel({
    required this.totalEarnings,
    required this.growth,
    required this.accountNumber,
    required this.ordersCompleted,
    required this.averageOrderValue,
    required this.pendingPayout,
  });
}

class WeeklyIncomeModel {
  final String week;
  final double amount;

  const WeeklyIncomeModel({
    required this.week,
    required this.amount,
  });
}

class TransactionModel {
  final String title;
  final String date;
  final double amount;
  final bool isIncome;

  const TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });
}