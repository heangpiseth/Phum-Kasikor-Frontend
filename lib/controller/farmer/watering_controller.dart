import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/watering_log_model.dart';

class WateringController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================

  final RxList<WateringModel> wateringLogs =
      <WateringModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxBool isSaving = false.obs;

  final RxnString errorMessage = RxnString();

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadWateringLogs();
  }

  // ============================================================
  // LOAD WATERING LOGS
  // ============================================================

  Future<void> loadWateringLogs() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await ApiClient.get(
        'farmer/watering-logs',
      );

      final body = _normalizeResponse(response);

      if (body['success'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Failed to load watering logs.',
        );
      }

      final rawData = body['data'];

      if (rawData is! List) {
        wateringLogs.clear();
        return;
      }

      final logs = <WateringModel>[];

      for (final item in rawData) {
        if (item is! Map) {
          continue;
        }

        try {
          logs.add(
            WateringModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Ignore one malformed record instead of
          // breaking the whole watering screen.
        }
      }

      wateringLogs.assignAll(logs);
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshWateringLogs() async {
    await loadWateringLogs();
  }

  // ============================================================
  // RECORD WATERING
  // ============================================================

  Future<bool> logWatering({
    required String cropId,
    String? fieldName,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      // cropId is now a String.
      // Make sure it is not empty and represents a valid ID.
      final parsedCropId = int.tryParse(cropId);

      if (cropId.trim().isEmpty ||
          parsedCropId == null ||
          parsedCropId <= 0) {
        errorMessage.value = 'Invalid crop.';
        return false;
      }

      if (amount <= 0) {
        errorMessage.value =
            'Water amount must be greater than 0.';
        return false;
      }

      final body = <String, dynamic>{
        'crop_id': cropId,
        'watering_date': _formatDate(date),
        'water_amount': amount,
      };

      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }

      /*
       * fieldName is intentionally not sent.
       *
       * The Laravel backend already knows the crop and can
       * determine the crop's field from crop_id.
       */

      final response = await ApiClient.post(
        'farmer/watering-logs',
        body,
      );

      final responseBody =
          _normalizeResponse(response);

      if (responseBody['success'] != true) {
        throw Exception(
          responseBody['message']?.toString() ??
              'Failed to record watering.',
        );
      }

      await loadWateringLogs();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // ADD WATERING LOG
  // ============================================================

  Future<bool> addWateringLog({
    required String cropId,
    int? fieldId,
    required DateTime wateringDate,
    double? waterAmount,
    String? notes,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      // cropId is a String because CropModel.id is a String.
      final parsedCropId = int.tryParse(cropId);

      if (cropId.trim().isEmpty ||
          parsedCropId == null ||
          parsedCropId <= 0) {
        errorMessage.value = 'Invalid crop.';
        return false;
      }

      final body = <String, dynamic>{
        'crop_id': cropId,
        'watering_date': _formatDate(wateringDate),
      };

      if (fieldId != null) {
        body['field_id'] = fieldId;
      }

      if (waterAmount != null) {
        body['water_amount'] = waterAmount;
      }

      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }

      final response = await ApiClient.post(
        'farmer/watering-logs',
        body,
      );

      final responseBody =
          _normalizeResponse(response);

      if (responseBody['success'] != true) {
        throw Exception(
          responseBody['message']?.toString() ??
              'Failed to create watering log.',
        );
      }

      await loadWateringLogs();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPDATE WATERING LOG
  // ============================================================

  Future<bool> updateWateringLog({
    required String id,
    String? cropId,
    int? fieldId,
    DateTime? wateringDate,
    double? waterAmount,
    String? notes,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      final body = <String, dynamic>{};

      if (cropId != null) {
        final parsedCropId = int.tryParse(cropId);

        if (cropId.trim().isEmpty ||
            parsedCropId == null ||
            parsedCropId <= 0) {
          errorMessage.value = 'Invalid crop.';
          return false;
        }

        body['crop_id'] = cropId;
      }

      if (fieldId != null) {
        body['field_id'] = fieldId;
      }

      if (wateringDate != null) {
        body['watering_date'] =
            _formatDate(wateringDate);
      }

      if (waterAmount != null) {
        body['water_amount'] = waterAmount;
      }

      if (notes != null) {
        body['notes'] = notes.trim();
      }

      final response = await ApiClient.put(
        'farmer/watering-logs/$id',
        body,
      );

      final responseBody =
          _normalizeResponse(response);

      if (responseBody['success'] != true) {
        throw Exception(
          responseBody['message']?.toString() ??
              'Failed to update watering log.',
        );
      }

      await loadWateringLogs();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE WATERING LOG
  // ============================================================

  Future<bool> deleteWateringLog(int id) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      final response = await ApiClient.delete(
        'farmer/watering-logs/$id',
      );

      final body = _normalizeResponse(response);

      if (body['success'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Failed to delete watering log.',
        );
      }

      wateringLogs.removeWhere(
        (log) => log.id == id,
      );

      wateringLogs.refresh();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // GET LOGS FOR CROP
  // ============================================================

  List<WateringModel> getLogsByCrop(String cropId) {
    final logs = wateringLogs
        .where(
          (log) => log.cropId == cropId,
        )
        .toList();

    logs.sort(
      (a, b) => b.wateringDate.compareTo(
        a.wateringDate,
      ),
    );

    return logs;
  }

  // ============================================================
  // SAME AS getLogsByCrop
  // ============================================================

  List<WateringModel> getLogsForCrop(String cropId) {
    return getLogsByCrop(cropId);
  }

  // ============================================================
  // GET LAST WATERING
  // ============================================================

  WateringModel? getLastWatering(String cropId) {
    final logs = getLogsByCrop(cropId);

    if (logs.isEmpty) {
      return null;
    }

    return logs.first;
  }

  // ============================================================
  // SAME AS getLastWatering
  // ============================================================

  WateringModel? getLatestLogForCrop(String cropId) {
    return getLastWatering(cropId);
  }

  // ============================================================
  // HAS WATERED TODAY
  // ============================================================

  bool hasWateredToday(String cropId) {
    final today = _dateOnly(DateTime.now());

    return wateringLogs.any(
      (log) {
        if (log.cropId != cropId) {
          return false;
        }

        final wateringDate =
            _dateOnly(log.wateringDate);

        return wateringDate == today;
      },
    );
  }

  // ============================================================
  // TOTAL WATER USED TODAY
  // ============================================================

  double get totalWaterUsedToday {
    final today = _dateOnly(DateTime.now());

    return wateringLogs
        .where(
          (log) =>
              _dateOnly(log.wateringDate) == today,
        )
        .fold<double>(
          0,
          (total, log) =>
              total + (log.waterAmount ?? 0),
        );
  }

  // ============================================================
  // TOTAL WATER USED THIS WEEK
  // ============================================================

  double get totalWaterUsedThisWeek {
    final now = DateTime.now();

    final today = _dateOnly(now);

    /*
     * Monday is the first day of the week.
     */

    final daysFromMonday =
        today.weekday - DateTime.monday;

    final startOfWeek = today.subtract(
      Duration(days: daysFromMonday),
    );

    return wateringLogs
        .where(
          (log) {
            final date =
                _dateOnly(log.wateringDate);

            return !date.isBefore(startOfWeek) &&
                !date.isAfter(today);
          },
        )
        .fold<double>(
          0,
          (total, log) =>
              total + (log.waterAmount ?? 0),
        );
  }

  // ============================================================
  // TOTAL WATER FOR CROP
  // ============================================================

  double getTotalWaterForCrop(String cropId) {
    return getLogsByCrop(cropId).fold<double>(
      0,
      (total, log) =>
          total + (log.waterAmount ?? 0),
    );
  }

  // ============================================================
  // LAST WATERING AMOUNT
  // ============================================================

  double getLastWaterAmount(String cropId) {
    final last = getLastWatering(cropId);

    return last?.waterAmount ?? 0;
  }

  // ============================================================
  // RESPONSE NORMALIZER
  // ============================================================

  Map<String, dynamic> _normalizeResponse(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception(
      'Invalid server response.',
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final year =
        date.year.toString().padLeft(4, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ============================================================
  // DATE ONLY
  // ============================================================

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(dynamic error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    errorMessage.value = null;
  }
}