import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/earnings_model.dart';

class EarningsController extends GetxController {
  final earnings = Rxn<EarningsModel>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Selected graph range.
  ///
  /// 6 = last 6 months
  /// 12 = last 12 months
  /// 0 = all available months
  final selectedRange = 6.obs;

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/earnings',
      );

      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;

      earnings.value = EarningsModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEarnings() async {
    await loadEarnings();
  }

  void changeRange(int range) {
    selectedRange.value = range;
  }

  List<EarningsPoint> get filteredPoints {
    final model = earnings.value;

    if (model == null) {
      return [];
    }

    final points = List<EarningsPoint>.from(
      model.monthlyEarnings,
    );

    if (selectedRange.value == 0) {
      return points;
    }

    if (points.length <= selectedRange.value) {
      return points;
    }

    return points.sublist(
      points.length - selectedRange.value,
    );
  }

  String _cleanError(dynamic error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}