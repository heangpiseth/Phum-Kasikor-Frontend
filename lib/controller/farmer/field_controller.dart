import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';

class FieldController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================

  final fields = <FieldModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final errorMessage = ''.obs;

  // ============================================================
  // LOAD FIELDS
  // ============================================================

  Future<void> loadFields(String farmId) async {
    final resolvedFarmId = farmId.trim();

    if (resolvedFarmId.isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      fields.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.get(
        'farmer/farms/$resolvedFarmId/fields',
      );

      final rawFields = _extractFields(response);

      if (rawFields == null) {
        fields.clear();
        return;
      }

      final parsedFields = <FieldModel>[];

      for (final item in rawFields) {
        if (item is! Map) continue;

        try {
          parsedFields.add(
            FieldModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Ignore malformed individual records.
        }
      }

      fields.assignAll(parsedFields);
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshFields(String farmId) async {
    await loadFields(farmId);
  }

  // ============================================================
  // GET FIELD
  // ============================================================

  FieldModel? getFieldById(String fieldId) {
    try {
      return fields.firstWhere(
        (field) => field.id == fieldId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CREATE FIELD
  // ============================================================

  Future<bool> createField({
    required String farmId,
    required String name,
    double? area,
    String? soilType,
    String? description,
  }) async {
    final resolvedFarmId = farmId.trim();
    final resolvedName = name.trim();

    if (resolvedFarmId.isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    if (resolvedName.isEmpty) {
      errorMessage.value = 'Field name is required.';
      return false;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      final body = <String, dynamic>{
        'name': resolvedName,
        if (area != null) 'area': area,
        if (soilType != null && soilType.trim().isNotEmpty)
          'soil_type': soilType.trim(),
        if (description != null &&
            description.trim().isNotEmpty)
          'description': description.trim(),
      };

      final response = await ApiClient.post(
        'farmer/farms/$resolvedFarmId/fields',
        body,
      );

      final createdJson = _extractField(response);

      if (createdJson != null) {
        final createdField = FieldModel.fromJson(
          createdJson,
        );

        fields.insert(0, createdField);
      } else {
        // API succeeded but did not return the created record.
        // Reload so the UI still gets the real database record.
        await loadFields(resolvedFarmId);
      }

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // UPDATE FIELD
  // ============================================================

  Future<bool> updateField({
    required String farmId,
    required String fieldId,
    required Map<String, dynamic> data,
  }) async {
    final resolvedFarmId = farmId.trim();
    final resolvedFieldId = fieldId.trim();

    if (resolvedFarmId.isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    if (resolvedFieldId.isEmpty) {
      errorMessage.value = 'Field ID is missing.';
      return false;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      final response = await ApiClient.put(
        'farmer/farms/$resolvedFarmId/fields/$resolvedFieldId',
        data,
      );

      final updatedJson = _extractField(response);

      if (updatedJson != null) {
        final updatedField = FieldModel.fromJson(
          updatedJson,
        );

        final index = fields.indexWhere(
          (field) => field.id == resolvedFieldId,
        );

        if (index == -1) {
          fields.insert(0, updatedField);
        } else {
          fields[index] = updatedField;
        }

        fields.refresh();
      } else {
        await loadFields(resolvedFarmId);
      }

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE FIELD
  // ============================================================

  Future<bool> deleteField({
    required String farmId,
    required String fieldId,
  }) async {
    final resolvedFarmId = farmId.trim();
    final resolvedFieldId = fieldId.trim();

    if (resolvedFarmId.isEmpty) {
      errorMessage.value = 'Farm ID is missing.';
      return false;
    }

    if (resolvedFieldId.isEmpty) {
      errorMessage.value = 'Field ID is missing.';
      return false;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      await ApiClient.delete(
        'farmer/farms/$resolvedFarmId/fields/$resolvedFieldId',
      );

      fields.removeWhere(
        (field) => field.id == resolvedFieldId,
      );

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  List<dynamic>? _extractFields(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is! Map) {
      return null;
    }

    if (response['fields'] is List) {
      return response['fields'] as List;
    }

    if (response['data'] is List) {
      return response['data'] as List;
    }

    if (response['data'] is Map &&
        response['data']['fields'] is List) {
      return response['data']['fields'] as List;
    }

    return null;
  }

  Map<String, dynamic>? _extractField(dynamic response) {
    if (response is! Map) {
      return null;
    }

    if (response['field'] is Map) {
      return Map<String, dynamic>.from(
        response['field'],
      );
    }

    if (response['data'] is Map) {
      final data = Map<String, dynamic>.from(
        response['data'],
      );

      if (data['field'] is Map) {
        return Map<String, dynamic>.from(
          data['field'],
        );
      }

      if (data['id'] != null) {
        return data;
      }
    }

    if (response['id'] != null) {
      return Map<String, dynamic>.from(response);
    }

    return null;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(dynamic error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    errorMessage.value = '';
  }

  // ============================================================
  // CLEAR FIELDS
  // ============================================================

  void clearFields() {
    fields.clear();
  }
}