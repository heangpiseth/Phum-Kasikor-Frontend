import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';

class LocationSetupController extends GetxController {
  // ============================================================
  // MAP
  // ============================================================

  GoogleMapController? mapController;

  // Default Cambodia / Phnom Penh position.
  // This is only used until the user's real location is detected.
  final pickedLocation = const LatLng(
    11.562103,
    104.8903934,
  ).obs;

  // ============================================================
  // LOCATION DATA
  // ============================================================

  final latitude = RxnDouble();
  final longitude = RxnDouble();

  final selectedProvince = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedCommune = ''.obs;

  final formattedAddress = ''.obs;

  // ============================================================
  // STATES
  // ============================================================

  final isLocating = false.obs;
  final isDetectingAddress = false.obs;
  final isSubmitting = false.obs;

  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();

    // Try to get the current location when the page opens.
    selectLocation(pickedLocation.value);
  }

  // ============================================================
  // MAP CREATED
  // ============================================================

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ============================================================
  // PIN MOVED
  // ============================================================

  Future<void> onPinMoved(LatLng location) async {
    await selectLocation(location);
  }

  // ============================================================
  // SELECT LOCATION
  // ============================================================

  Future<void> selectLocation(LatLng location) async {
    errorMessage.value = null;

    pickedLocation.value = location;

    latitude.value = location.latitude;
    longitude.value = location.longitude;

    await _reverseGeocode(location);

    // Move camera to selected position.
    try {
      await mapController?.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    } catch (_) {
      // Camera animation is optional.
    }
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> useCurrentLocation() async {
    try {
      errorMessage.value = null;
      isLocating.value = true;

      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        errorMessage.value =
            'Location service is disabled. Please enable GPS and try again.';
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        errorMessage.value =
            'Location permission was denied.';
        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        errorMessage.value =
            'Location permission is permanently denied. Please enable it in your phone settings.';
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      await selectLocation(location);

      try {
        await mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 16,
            ),
          ),
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value =
          'Unable to get your current location.';
      debugPrint(
        'LocationSetupController.useCurrentLocation error: $e',
      );
    } finally {
      isLocating.value = false;
    }
  }

  // ============================================================
  // REVERSE GEOCODE
  // ============================================================

  Future<void> _reverseGeocode(
    LatLng location,
  ) async {
    try {
      isDetectingAddress.value = true;
      errorMessage.value = null;

      final response = await ApiClient.post(
        'location/reverse-geocode',
        {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      );

      debugPrint(
        'Reverse geocode response: $response',
      );

      if (response is Map<String, dynamic>) {
        final locationData = response['location'];

        if (locationData is Map<String, dynamic>) {
          formattedAddress.value =
              _stringValue(locationData['formatted_address']);

          selectedProvince.value =
              _stringValue(locationData['province']);

          selectedDistrict.value =
              _stringValue(locationData['district']);

          selectedCommune.value =
              _stringValue(locationData['commune']);
        }
      }
    } catch (e) {
      debugPrint(
        'Reverse geocode error: $e',
      );

      // Do not destroy the coordinates if reverse
      // geocoding fails.
      //
      // The user can still confirm the GPS location.
      formattedAddress.value = '';
      selectedProvince.value = '';
      selectedDistrict.value = '';
      selectedCommune.value = '';
    } finally {
      isDetectingAddress.value = false;
    }
  }

  // ============================================================
  // CONFIRM LOCATION
  // ============================================================

  Future<void> setLocationAndContinue() async {
    if (isSubmitting.value) {
      return;
    }

    errorMessage.value = null;

    // ----------------------------------------------------------
    // Make sure coordinates exist
    // ----------------------------------------------------------

    final lat = latitude.value;
    final lng = longitude.value;

    if (lat == null || lng == null) {
      errorMessage.value =
          'Please select your farm location on the map first.';
      return;
    }

    // ----------------------------------------------------------
    // Province is required by the Laravel endpoint.
    // ----------------------------------------------------------

    final province =
        selectedProvince.value.trim();

    final district =
        selectedDistrict.value.trim();

    final commune =
        selectedCommune.value.trim();

    if (province.isEmpty) {
      // Try one final reverse geocode before rejecting.
      await _reverseGeocode(
        pickedLocation.value,
      );
    }

    final finalProvince =
        selectedProvince.value.trim();

    if (finalProvince.isEmpty) {
      errorMessage.value =
          'We could not detect your province. Please move the pin and try again.';
      return;
    }

    try {
      isSubmitting.value = true;

      // ========================================================
      // SEND TO LARAVEL
      // ========================================================

      final requestBody = {
        'province': finalProvince,
        'district':
            district.isEmpty ? null : district,
        'commune':
            commune.isEmpty ? null : commune,
        'latitude': lat,
        'longitude': lng,
      };

      debugPrint(
        'Saving farmer location: $requestBody',
      );

      final response = await ApiClient.put(
        'profile/location',
        requestBody,
      );

      debugPrint(
        'Save location response: $response',
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      Get.offAllNamed(
        AppRoutes.farmerHome,
      );
    } catch (e) {
      debugPrint(
        'Save farmer location error: $e',
      );

      errorMessage.value =
          _getReadableError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // STRING HELPER
  // ============================================================

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ============================================================
  // ERROR HELPER
  // ============================================================

  String _getReadableError(Object error) {
    final message = error.toString();

    if (message.contains('401')) {
      return 'Your session has expired. Please log in again.';
    }

    if (message.contains('422')) {
      return 'Please check the location information and try again.';
    }

    if (message.contains('500')) {
      return 'The server could not save your location. Please try again.';
    }

    if (message.isNotEmpty) {
      return message
          .replaceFirst('Exception: ', '')
          .trim();
    }

    return 'Could not save your farm location. Please try again.';
  }
}