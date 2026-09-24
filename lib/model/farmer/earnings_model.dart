class EarningsPoint {
  final String month;
  final double amount;

  EarningsPoint({
    required this.month,
    required this.amount,
  });

  factory EarningsPoint.fromJson(Map<String, dynamic> json) {
    return EarningsPoint(
      month: json['month']?.toString() ?? '',
      amount: _toDouble(json['amount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class EarningsModel {
  final double totalEarnings;
  final double thisMonth;
  final List<EarningsPoint> monthlyEarnings;

  EarningsModel({
    required this.totalEarnings,
    required this.thisMonth,
    required this.monthlyEarnings,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final rawMonthly = json['monthly_earnings'];

    final monthly = <EarningsPoint>[];

    if (rawMonthly is List) {
      for (final item in rawMonthly) {
        if (item is Map) {
          monthly.add(
            EarningsPoint.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return EarningsModel(
      totalEarnings: _toDouble(json['total_earnings']),
      thisMonth: _toDouble(json['this_month']),
      monthlyEarnings: monthly,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}