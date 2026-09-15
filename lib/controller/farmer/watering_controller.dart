import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/watering_log_model.dart';


class WateringController extends GetxController {
  final wateringLogs = <WateringLogModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedCropId = Rxn<String>();

  List<WateringLogModel> get filteredLogs {
    if (selectedCropId.value == null) {
      return wateringLogs;
    }
    return wateringLogs
        .where((log) => log.cropId == selectedCropId.value)
        .toList();
  }

  List<WateringLogModel> get todayLogs {
    final today = DateTime.now();
    return wateringLogs
        .where(
          (log) =>
              log.date.year == today.year &&
              log.date.month == today.month &&
              log.date.day == today.day,
        )
        .toList();
  }

  double get totalWaterUsedToday =>
      todayLogs.fold(0, (sum, log) => sum + log.amount);

  double get totalWaterUsedThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return wateringLogs
        .where((log) => log.date.isAfter(weekAgo))
        .fold(0, (sum, log) => sum + log.amount);
  }

  Map<String, double> get waterUsageByCrop {
    final map = <String, double>{};
    for (final log in wateringLogs) {
      map[log.cropId] = (map[log.cropId] ?? 0) + log.amount;
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    loadWateringLogs();
  }

  Future<void> loadWateringLogs() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));

      wateringLogs.assignAll([
        WateringLogModel(
          id: 'log-1',
          cropId: 'crop-1',
          fieldName: 'Field A',
          date: DateTime(2024, 12, 1, 7, 0),
          amount: 50.0,
          notes: 'Morning watering',
        ),
        WateringLogModel(
          id: 'log-2',
          cropId: 'crop-1',
          fieldName: 'Field A',
          date: DateTime(2024, 12, 2, 7, 0),
          amount: 55.0,
          notes: 'Morning watering',
        ),
        WateringLogModel(
          id: 'log-3',
          cropId: 'crop-2',
          fieldName: 'Field B',
          date: DateTime(2024, 12, 3, 18, 0),
          amount: 30.0,
          notes: 'Evening watering',
        ),
        WateringLogModel(
          id: 'log-4',
          cropId: 'crop-1',
          fieldName: 'Field A',
          date: DateTime(2024, 12, 4, 7, 0),
          amount: 60.0,
          notes: 'Increased amount due to dry weather',
        ),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshWateringLogs() async {
    await loadWateringLogs();
  }

  void selectCrop(String? cropId) {
    selectedCropId.value = cropId;
  }

  void clearCropFilter() {
    selectedCropId.value = null;
  }

  Future<bool> addWateringLog(WateringLogModel log) async {
    try {
      wateringLogs.add(log);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateWateringLog(
    String logId,
    WateringLogModel updatedLog,
  ) async {
    try {
      final index = wateringLogs.indexWhere((log) => log.id == logId);
      if (index >= 0) {
        wateringLogs[index] = updatedLog;
        wateringLogs.refresh();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteWateringLog(String logId) async {
    try {
      final index = wateringLogs.indexWhere((log) => log.id == logId);
      if (index >= 0) {
        wateringLogs.removeAt(index);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  WateringLogModel? getLogById(String logId) {
    try {
      return wateringLogs.firstWhere((log) => log.id == logId);
    } catch (e) {
      return null;
    }
  }

  List<WateringLogModel> getLogsByCrop(String cropId) {
    return wateringLogs.where((log) => log.cropId == cropId).toList();
  }

  List<WateringLogModel> getLogsByDateRange(DateTime start, DateTime end) {
    return wateringLogs
        .where(
          (log) =>
              log.date.isAfter(start.subtract(const Duration(days: 1))) &&
              log.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  Future<bool> logWatering({
    required String cropId,
    required String fieldName,
    required double amount,
    String? notes,
  }) async {
    final log = WateringLogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      cropId: cropId,
      fieldName: fieldName,
      date: DateTime.now(),
      amount: amount,
      notes: notes,
    );
    return addWateringLog(log);
  }
}
