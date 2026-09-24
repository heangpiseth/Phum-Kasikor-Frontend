import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/farmer_profile_model.dart';
import 'package:phum_kasikors/model/farmer/user_model.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_edit_profile_screen.dart';

class FarmerProfileController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  final isUploadingImage = false.obs;

  final errorMessage = RxnString();

  final profile = Rxn<FarmerProfileModel>();
  final userInfo = Rxn<UserModel>();

    // ============================================================
  // PROFILE DISPLAY DATA
  // ============================================================

  final name = 'Farmer'.obs;
  final displayName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final location = ''.obs;
  final bio = ''.obs;
  final gender = ''.obs;
  final dateOfBirth = ''.obs;
  final role = 'farmer'.obs;
  final profileImage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await ApiClient.get('me');

      if (response is! Map) {
        throw Exception('Invalid profile response.');
      }

      final responseMap = Map<String, dynamic>.from(response);

      final userData = responseMap['user'] is Map
          ? Map<String, dynamic>.from(responseMap['user'])
          : responseMap;

            name.value =
          _stringValue(userData['name']) ??
          _stringValue(userData['display_name']) ??
          'Farmer';

      displayName.value =
          _stringValue(userData['display_name']) ?? '';

      email.value =
          _stringValue(userData['email']) ?? '';

      phone.value =
          _stringValue(userData['phone']) ?? '';

      location.value =
          _stringValue(userData['location']) ?? '';

      bio.value =
          _stringValue(userData['bio']) ?? '';

      gender.value =
          _stringValue(userData['gender']) ?? '';

      dateOfBirth.value =
          _stringValue(userData['date_of_birth']) ?? '';

      role.value =
          _stringValue(userData['role']) ?? 'farmer';

      profileImage.value =
          _stringValue(userData['profile_image']);

      userInfo.value = UserModel.fromJson(userData);
      profile.value = FarmerProfileModel.fromJson(userData);
    } catch (e) {
      errorMessage.value = _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
// PICK PROFILE IMAGE
// ============================================================

Future<void> pickProfileImage(ImageSource source) async {
  try {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (pickedFile == null) {
      return;
    }

    await uploadProfileImage(pickedFile.path);
  } catch (e) {
    errorMessage.value = _cleanError(e);

    Get.snackbar(
      'Image Error',
      errorMessage.value ?? 'Unable to select image.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// ============================================================
// UPLOAD PROFILE IMAGE
// ============================================================

Future<bool> uploadProfileImage(String imagePath) async {
  isUploadingImage.value = true;
  errorMessage.value = null;

  try {
    final response = await ApiClient.postMultipart(
      'profile/image',
      fields: {},
      files: {
        'image': imagePath,
      },
    );

    if (response is Map) {
      final responseMap =
          Map<String, dynamic>.from(response);

      final userData = responseMap['user'] is Map
          ? Map<String, dynamic>.from(
              responseMap['user'],
            )
          : null;

      if (userData != null) {
        userInfo.value =
            UserModel.fromJson(userData);

        profile.value =
            FarmerProfileModel.fromJson(userData);

                    name.value =
            _stringValue(userData['name']) ??
            _stringValue(userData['display_name']) ??
            'Farmer';

        displayName.value =
            _stringValue(userData['display_name']) ?? '';

        email.value =
            _stringValue(userData['email']) ?? '';

        phone.value =
            _stringValue(userData['phone']) ?? '';

        location.value =
            _stringValue(userData['location']) ?? '';

        bio.value =
            _stringValue(userData['bio']) ?? '';

        gender.value =
            _stringValue(userData['gender']) ?? '';

        dateOfBirth.value =
            _stringValue(userData['date_of_birth']) ?? '';

        role.value =
            _stringValue(userData['role']) ?? 'farmer';

        profileImage.value =
            _stringValue(userData['profile_image']);
      } else {
        await loadProfile();
      }
    } else {
      await loadProfile();
    }

    Get.snackbar(
      'Profile Photo',
      'Profile photo updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );

    return true;
  } catch (e) {
    errorMessage.value = _cleanError(e);

    Get.snackbar(
      'Upload Failed',
      errorMessage.value ?? 'Unable to upload profile photo.',
      snackPosition: SnackPosition.BOTTOM,
    );

    return false;
  } finally {
    isUploadingImage.value = false;
  }
}

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile({
    String? name,
    String? displayName,
    String? bio,
    String? gender,
    String? dateOfBirth,
    String? location,
    String? profileImage,
  }) async {
    isSaving.value = true;
    errorMessage.value = null;

    try {
      final body = <String, dynamic>{};

      if (name != null) {
        body['name'] = name.trim();
      }

      if (displayName != null) {
        body['display_name'] = displayName.trim();
      }

      if (bio != null) {
        body['bio'] = bio.trim();
      }

      if (gender != null) {
        body['gender'] = gender;
      }

      if (dateOfBirth != null) {
        body['date_of_birth'] = dateOfBirth;
      }

      if (location != null) {
        body['location'] = location.trim();
      }

      if (profileImage != null) {
        body['profile_image'] = profileImage.trim();
      }

      final response = await ApiClient.put('profile', body);

      if (response is Map) {
        final responseMap = Map<String, dynamic>.from(response);

        final userData = responseMap['user'] is Map
            ? Map<String, dynamic>.from(responseMap['user'])
            : responseMap;

        userInfo.value = UserModel.fromJson(userData);

        profile.value = FarmerProfileModel.fromJson(userData);
      } else {
        await loadProfile();
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
  // EDIT PROFILE
  // ============================================================

  Future<bool?> editProfile() async {
    return Get.to<bool>(() => const FarmerEditProfileScreen());
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await ApiClient.post('profile/logout', {});
    } catch (_) {
      // Local session cleanup can be handled
      // by the existing authentication flow.
    }

    Get.snackbar(
      'Logout',
      'Logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

    String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty || result == 'null') {
      return null;
    }

    return result;
  }
}
