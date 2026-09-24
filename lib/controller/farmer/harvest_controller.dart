import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';

class HarvestController extends GetxController {
  final RxList<Map<String, dynamic>> harvests =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  // ============================================================
  // LOAD HARVESTS
  // ============================================================

  Future<void> loadHarvests() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.get('farmer/harvests');

      dynamic data = response;

      if (response is Map) {
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['harvests'] is List) {
          data = response['harvests'];
        }
      }

      if (data is List) {
        harvests.assignAll(
          data
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList(),
        );
      } else {
        harvests.clear();
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE HARVEST
  // ============================================================

  Future<bool> createHarvest({
    required String cropId,
    required String harvestDate,
    required double quantity,
    required String quality,
    required String condition,
    String? notes,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final parsedCropId = int.tryParse(cropId);

      if (parsedCropId == null) {
        errorMessage.value = 'Invalid crop selected.';
        return false;
      }

      final body = <String, dynamic>{
        'crop_id': parsedCropId,
        'harvest_date': harvestDate,
        'quantity': quantity,
        'quality': quality.trim().toLowerCase(),
        'condition': condition.trim().toLowerCase(),
      };

      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }

      await ApiClient.post(
        'farmer/harvests',
        body,
      );

      await loadHarvests();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPDATE HARVEST
  // ============================================================

  Future<bool> updateHarvest({
    required String harvestId,
    required String harvestDate,
    required double quantity,
    required String quality,
    required String condition,
    String? notes,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final body = <String, dynamic>{
        'harvest_date': harvestDate,
        'quantity': quantity,
        'quality': quality.trim().toLowerCase(),
        'condition': condition.trim().toLowerCase(),
      };

      if (notes != null) {
        body['notes'] = notes.trim();
      }

      await ApiClient.put(
        'farmer/harvests/$harvestId',
        body,
      );

      await loadHarvests();

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE HARVEST
  // ============================================================

  Future<bool> deleteHarvest(String harvestId) async {
    errorMessage.value = '';

    try {
      await ApiClient.delete(
        'farmer/harvests/$harvestId',
      );

      harvests.removeWhere(
        (item) => item['id']?.toString() == harvestId,
      );

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    }
  }

  // ============================================================
  // ERROR CLEANUP
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}