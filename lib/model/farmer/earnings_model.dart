class EarningsModel {
  double totalEarnings;
  double growth;
  int ordersCompleted;
  double avgOrderValue;
  double pendingPayout;
  List<double> weeklyIncome;
  List<TransactionModel> transactions;

  EarningsModel({
    required this.totalEarnings,
    required this.growth,
    required this.ordersCompleted,
    required this.avgOrderValue,
    required this.pendingPayout,
    required this.weeklyIncome,
    required this.transactions,
  });
}

class TransactionModel {
  String title;
  String date;
  double amount;
  bool isIncome;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });
}