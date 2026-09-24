import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:phum_kasikors/core/network/api_client.dart';

class FarmLocationController extends GetxController {
  FarmLocationController({
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  GoogleMapController? mapController;

  static const LatLng defaultLocation = LatLng(
    11.562103,
    104.8903934,
  );

  late final Rx<LatLng> pickedLocation;

  final latitude = RxnDouble();
  final longitude = RxnDouble();

  final formattedAddress = ''.obs;
  final selectedProvince = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedCommune = ''.obs;

  final isDetectingAddress = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final initialLocation =
        initialLatitude != null &&
                initialLongitude != null
            ? LatLng(
                initialLatitude!,
                initialLongitude!,
              )
            : defaultLocation;

    pickedLocation =
        initialLocation.obs;

    latitude.value =
        initialLocation.latitude;

    longitude.value =
        initialLocation.longitude;

    formattedAddress.value =
        initialAddress?.trim() ?? '';

    // Detect the address from the existing
    // coordinates when opening the screen.
    if (initialLatitude != null &&
        initialLongitude != null) {
      _reverseGeocode(
        initialLocation,
      );
    }
  }

  void onMapCreated(
    GoogleMapController controller,
  ) {
    mapController = controller;
  }

  Future<void> onPinMoved(
    LatLng location,
  ) async {
    await selectLocation(location);
  }

  Future<void> selectLocation(
    LatLng location,
  ) async {
    errorMessage.value = '';

    pickedLocation.value = location;

    latitude.value =
        location.latitude;

    longitude.value =
        location.longitude;

    await _reverseGeocode(location);

    try {
      await mapController?.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    } catch (_) {}
  }

  Future<void> _reverseGeocode(
    LatLng location,
  ) async {
    try {
      isDetectingAddress.value = true;
      errorMessage.value = '';

      final response =
          await ApiClient.post(
        'location/reverse-geocode',
        {
          'latitude':
              location.latitude,
          'longitude':
              location.longitude,
        },
      );

      debugPrint(
        'Farm reverse geocode response: $response',
      );

      if (response is Map) {
        final responseMap =
            Map<String, dynamic>.from(
          response,
        );

        final locationData =
            responseMap['location'];

        if (locationData is Map) {
          final data =
              Map<String, dynamic>.from(
            locationData,
          );

          formattedAddress.value =
              _stringValue(
            data['formatted_address'],
          );

          selectedProvince.value =
              _stringValue(
            data['province'],
          );

          selectedDistrict.value =
              _stringValue(
            data['district'],
          );

          selectedCommune.value =
              _stringValue(
            data['commune'],
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Farm reverse geocode error: $e',
      );

      // Keep the coordinates even if
      // reverse geocoding fails.
      if (formattedAddress.value.isEmpty) {
        formattedAddress.value =
            initialAddress?.trim() ?? '';
      }
    } finally {
      isDetectingAddress.value = false;
    }
  }

  Map<String, dynamic> get locationResult {
    final lat = latitude.value;
    final lng = longitude.value;

    return {
      'latitude': lat,
      'longitude': lng,
      'location':
          formattedAddress.value.trim(),
    };
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value
        .toString()
        .trim();
  }
}