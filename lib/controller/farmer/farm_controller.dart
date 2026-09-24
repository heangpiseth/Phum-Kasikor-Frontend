import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/farm_model.dart';

class FarmController extends GetxController {
  final Rxn<FarmModel> farm = Rxn<FarmModel>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  String? get currentFarmId => farm.value?.id;

  @override
  void onInit() {
    super.onInit();
    loadFarm();
  }

  // ============================================================
  // LOAD FARM
  // ============================================================

  Future<void> loadFarm() async {
  if (isLoading.value) {
    while (isLoading.value) {
      await Future.delayed(
        const Duration(milliseconds: 50),
      );
    }

    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    final response = await ApiClient.get(
      'farmer/farms',
    );

    print('========== FARM API RESPONSE ==========');
print(response);
print('=======================================');

    FarmModel? loadedFarm;

    if (response is List) {
      if (response.isNotEmpty) {
        final first = response.first;

        if (first is Map) {
          loadedFarm = FarmModel.fromJson(
            Map<String, dynamic>.from(first),
          );
        }
      }
    } else if (response is Map) {
      final map = Map<String, dynamic>.from(response);

      if (map['farm'] is Map) {
        loadedFarm = FarmModel.fromJson(
          Map<String, dynamic>.from(map['farm']),
        );
      } else if (map['farms'] is List &&
          (map['farms'] as List).isNotEmpty) {
        final first = (map['farms'] as List).first;

        if (first is Map) {
          loadedFarm = FarmModel.fromJson(
            Map<String, dynamic>.from(first),
          );
        }
      } else if (map['data'] is List &&
          (map['data'] as List).isNotEmpty) {
        final first = (map['data'] as List).first;

        if (first is Map) {
          loadedFarm = FarmModel.fromJson(
            Map<String, dynamic>.from(first),
          );
        }
      } else if (map['data'] is Map) {
        loadedFarm = FarmModel.fromJson(
          Map<String, dynamic>.from(map['data']),
        );
      } else if (map['id'] != null) {
        loadedFarm = FarmModel.fromJson(map);
      }
    }

    farm.value = loadedFarm;
  } catch (e) {
    errorMessage.value = _cleanError(e);
  } finally {
    isLoading.value = false;
  }
}

  // ============================================================
  // ENSURE FARM ID
  // ============================================================

  Future<String?> ensureFarmId() async {
    if (farm.value != null) {
      return farm.value!.id;
    }

    await loadFarm();

    return farm.value?.id;
  }

  // ============================================================
  // CREATE FARM
  // ============================================================

  Future<bool> createFarm({
    required String farmName,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    double? farmSize,
    String? farmingMethod,
    String? coverImage,
  }) async {
    final name = farmName.trim();

    if (name.isEmpty) {
      errorMessage.value =
          'Farm name is required.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.post(
        'farmer/farms',
        {
          'farm_name': name,
          'description':
              _nullableString(description),
          'location':
              _nullableString(location),
          'latitude': latitude,
          'longitude': longitude,
          'farm_size': farmSize,
          'farming_method':
              _nullableString(farmingMethod),
          'cover_image':
              _nullableString(coverImage),
        },
        
      );

      final farmData =
          _extractFarmData(response);

      if (farmData == null ||
          farmData['id'] == null) {
        errorMessage.value =
            'Farm was created, but the server returned invalid farm data.';
        return false;
      }

      farm.value = FarmModel.fromJson(
        farmData,
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
  // UPDATE FARM
  // ============================================================

  Future<bool> updateFarm({
    required String farmId,
    required String farmName,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    double? farmSize,
    String? farmingMethod,
    String? coverImage,
  }) async {
    final name = farmName.trim();

    if (farmId.trim().isEmpty) {
      errorMessage.value =
          'Farm ID is missing.';
      return false;
    }

    if (name.isEmpty) {
      errorMessage.value =
          'Farm name is required.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.put(
        'farmer/farms/$farmId',
        {
          'farm_name': name,
          'description':
              _nullableString(description),
          'location':
              _nullableString(location),
          'latitude': latitude,
          'longitude': longitude,
          'farm_size': farmSize,
          'farming_method':
              _nullableString(farmingMethod),
          'cover_image':
              _nullableString(coverImage),
        },
      );

      final farmData =
          _extractFarmData(response);

      if (farmData == null ||
          farmData['id'] == null) {
        errorMessage.value =
            'Farm was updated, but the server returned invalid farm data.';
        return false;
      }

      farm.value = FarmModel.fromJson(
        farmData,
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
  // DELETE FARM
  // ============================================================

  Future<bool> deleteFarm() async {
    final farmId = currentFarmId;

    if (farmId == null ||
        farmId.trim().isEmpty) {
      errorMessage.value =
          'Farm not found.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await ApiClient.delete(
        'farmer/farms/$farmId',
      );

      farm.value = null;

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // EXTRACT FARM DATA
  // ============================================================

  Map<String, dynamic>? _extractFarmData(
    dynamic response,
  ) {
    if (response is! Map) {
      return null;
    }

    final map =
        Map<String, dynamic>.from(response);

    // {
    //   "farm": {...}
    // }

    if (map['farm'] is Map) {
      return Map<String, dynamic>.from(
        map['farm'],
      );
    }

    // {
    //   "data": {...}
    // }

    if (map['data'] is Map) {
      return Map<String, dynamic>.from(
        map['data'],
      );
    }

    // Direct Farm model response.
    //
    // Laravel currently returns:
    //
    // return response()->json($farm, 201);
    //
    // and:
    //
    // return $farm;

    if (map['id'] != null) {
      return map;
    }

    return null;
  }

  // ============================================================
  // STRING CLEANUP
  // ============================================================

  String? _nullableString(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}