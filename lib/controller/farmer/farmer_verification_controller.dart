import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/core/network/api_exception.dart';
import 'package:phum_kasikors/model/farmer/verification_model.dart';

class FarmerVerificationController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // STATE
  // ============================================================

  final verification =
      Rxn<FarmerVerificationModel>();

  final frontImage = Rxn<File>();

  final backImage = Rxn<File>();

  final isLoading = false.obs;

  final isSubmitting = false.obs;

  final errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadVerification();
  }

  // ============================================================
  // LOAD VERIFICATION
  // ============================================================

  Future<void> loadVerification() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.get(
        'farmer/verification',
      );

      if (response is Map) {
        final data = Map<String, dynamic>.from(
          response,
        );

        final verificationData =
            data['verification'];

        if (verificationData is Map) {
          verification.value =
              FarmerVerificationModel.fromJson(
            Map<String, dynamic>.from(
              verificationData,
            ),
          );
        } else {
          verification.value = null;
        }
      } else {
        verification.value = null;
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // PICK FRONT IMAGE
  // ============================================================

  Future<void> pickFrontImage() async {
    final image = await _pickImage();

    if (image != null) {
      frontImage.value = image;
      errorMessage.value = '';
    }
  }

  // ============================================================
  // PICK BACK IMAGE
  // ============================================================

  Future<void> pickBackImage() async {
    final image = await _pickImage();

    if (image != null) {
      backImage.value = image;
      errorMessage.value = '';
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<File?> _pickImage() async {
    try {
      final source = await _showImageSourceDialog();

      if (source == null) {
        return null;
      }

      final XFile? pickedImage =
          await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (pickedImage == null) {
        return null;
      }

      final file = File(
        pickedImage.path,
      );

      if (!await file.exists()) {
        errorMessage.value =
            'The selected image could not be found.';
        return null;
      }

      return file;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return null;
    }
  }

  // ============================================================
  // CAMERA / GALLERY DIALOG
  // ============================================================

  Future<ImageSource?> _showImageSourceDialog() async {
    return Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text(
          'Choose image source',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
              ),
              title: const Text(
                'Take photo',
              ),
              onTap: () {
                Get.back(
                  result: ImageSource.camera,
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
              ),
              title: const Text(
                'Choose from gallery',
              ),
              onTap: () {
                Get.back(
                  result: ImageSource.gallery,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REMOVE IMAGES
  // ============================================================

  void removeFrontImage() {
    frontImage.value = null;
  }

  void removeBackImage() {
    backImage.value = null;
  }

  // ============================================================
  // SUBMIT VERIFICATION
  // ============================================================

  Future<bool> submitVerification({
    required String idNumber,
    required String fullName,
  }) async {
    errorMessage.value = '';

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (fullName.trim().isEmpty) {
      errorMessage.value =
          'Please enter your full name.';
      return false;
    }

    if (idNumber.trim().isEmpty) {
      errorMessage.value =
          'Please enter your National ID number.';
      return false;
    }

    if (frontImage.value == null) {
      errorMessage.value =
          'Please provide the front side of your National ID.';
      return false;
    }

    if (backImage.value == null) {
      errorMessage.value =
          'Please provide the back side of your National ID.';
      return false;
    }

    // ----------------------------------------------------------
    // START UPLOAD
    // ----------------------------------------------------------

    isSubmitting.value = true;

    try {
      final response =
          await ApiClient.postMultipart(
        'farmer/verification',

        fields: {
          'id_number': idNumber.trim(),
          'full_name': fullName.trim(),
        },

        files: {
          'front_image':
              frontImage.value!.path,

          'back_image':
              backImage.value!.path,
        },
      );

      // --------------------------------------------------------
      // HANDLE RESPONSE
      // --------------------------------------------------------

      if (response is Map) {
        final data = Map<String, dynamic>.from(
          response,
        );

        final verificationData =
            data['verification'];

        if (verificationData is Map) {
          verification.value =
              FarmerVerificationModel.fromJson(
            Map<String, dynamic>.from(
              verificationData,
            ),
          );
        }
      }

      // --------------------------------------------------------
      // CLEAR SELECTED FILES
      // --------------------------------------------------------

      frontImage.value = null;
      backImage.value = null;

      errorMessage.value = '';

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshVerification() async {
    await loadVerification();
  }

  // ============================================================
  // DELETE REJECTED VERIFICATION
  // ============================================================

  Future<bool> deleteRejectedVerification() async {
    final current = verification.value;

    if (current == null) {
      return false;
    }

    if (!current.isRejected) {
      errorMessage.value =
          'Only rejected verification can be removed.';
      return false;
    }

    try {
      await ApiClient.delete(
        'farmer/verification',
      );

      verification.value = null;
      frontImage.value = null;
      backImage.value = null;
      errorMessage.value = '';

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
    if (error is ApiException) {
      return error.message;
    }

    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}