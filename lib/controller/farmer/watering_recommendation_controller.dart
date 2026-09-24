import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';

import 'package:phum_kasikors/model/farmer/watering_recommendation_model.dart';

class WateringRecommendationController
    extends GetxController {
  final RxBool isLoading = false.obs;

  final Rxn<WateringRecommendationModel>
      recommendation = Rxn<WateringRecommendationModel>();

  final RxString errorMessage = ''.obs;

  Future<void> loadRecommendation(
    dynamic cropId,
  ) async {
    if (cropId == null) {
      errorMessage.value = 'Crop ID is required.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        '/farmer/watering-recommendation/$cropId',
      );

      final data = response['data'] ?? response;

      recommendation.value =
          WateringRecommendationModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      recommendation.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    recommendation.value = null;
    errorMessage.value = '';
  }
}