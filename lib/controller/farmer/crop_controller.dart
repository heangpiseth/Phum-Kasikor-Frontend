import 'dart:io';

import 'package:get/get.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';

class CropController extends GetxController {
  final crops = <CropModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final errorMessage = ''.obs;

  // ============================================================
  // LOAD CROPS
  // ============================================================

  Future<void> loadCrops(String farmId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/farms/$farmId/crops',
      );

      if (response is List) {
        crops.assignAll(
          response
              .map(
                (item) => CropModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      } else {
        crops.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE CROP
  // ============================================================

  Future<bool> createCrop({
    required String farmId,
    required String name,
    String? fieldId,
    String? variety,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? quantityPlanted,
    String? growthStage,
    File? imageFile,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final fields = <String, String>{
        'name': name,
      };

      if (fieldId != null && fieldId.isNotEmpty) {
        fields['field_id'] = fieldId;
      }

      if (variety != null && variety.trim().isNotEmpty) {
        fields['variety'] = variety.trim();
      }

      if (plantingDate != null) {
        fields['planting_date'] =
            _formatDate(plantingDate);
      }

      if (expectedHarvestDate != null) {
        fields['expected_harvest_date'] =
            _formatDate(expectedHarvestDate);
      }

      if (quantityPlanted != null) {
        fields['quantity_planted'] =
            quantityPlanted.toString();
      }

      if (growthStage != null &&
          growthStage.trim().isNotEmpty) {
        fields['growth_stage'] = growthStage.trim();
      }

      final files = <String, String>{};

      if (imageFile != null) {
        files['image'] = imageFile.path;
      }

      final response = await ApiClient.postMultipart(
        'farmer/farms/$farmId/crops',
        fields: fields,
        files: files,
      );

      CropModel? createdCrop;

      if (response is Map) {
        final json = Map<String, dynamic>.from(response);

        if (json['crop'] is Map) {
          createdCrop = CropModel.fromJson(
            Map<String, dynamic>.from(json['crop']),
          );
        } else if (json['id'] != null) {
          createdCrop = CropModel.fromJson(json);
        }
      }

      if (createdCrop != null) {
        crops.insert(0, createdCrop);
      } else {
        await loadCrops(farmId);
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPDATE CROP
  // ============================================================

  Future<bool> updateCrop({
    required String farmId,
    required String cropId,
    required Map<String, dynamic> data,
    File? imageFile,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final fields = <String, String>{
        '_method': 'PUT',
      };

      data.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      final files = <String, String>{};

      if (imageFile != null) {
        files['image'] = imageFile.path;
      }

      await ApiClient.postMultipart(
        'farmer/farms/$farmId/crops/$cropId',
        fields: fields,
        files: files,
      );

      await loadCrops(farmId);

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE CROP
  // ============================================================

  Future<bool> deleteCrop({
    required String farmId,
    required String cropId,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      await ApiClient.delete(
        'farmer/farms/$farmId/crops/$cropId',
      );

      crops.removeWhere(
        (crop) => crop.id == cropId,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // GET ONE CROP
  // ============================================================

  CropModel? getCropById(String cropId) {
    try {
      return crops.firstWhere(
        (crop) => crop.id == cropId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}