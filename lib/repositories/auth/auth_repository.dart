import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/farmer/user_model.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_response.dart';

class AuthRepository {
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    try {
      final json = await ApiClient.post('auth/register', {
        'name': name,
        // ignore: use_null_aware_elements
        if (email != null) 'email': email,
        // ignore: use_null_aware_elements
        if (phone != null) 'phone': phone,
        'password': password,
      });

      await TokenStorage.saveToken(json['token']);

      return ApiResponse.success({
        'user': UserModel.fromJson(json['user']),
        'token': json['token'] as String,
      });
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> verify({
    required int userId,
    required String code,
  }) async {
    try {
      final json = await ApiClient.post('auth/verify', {
        'user_id': userId,
        'code': code,
      });
      return ApiResponse.success(UserModel.fromJson(json['user']));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final json = await ApiClient.post('auth/login', {
        'identifier': identifier,
        'password': password,
      });
      await TokenStorage.saveToken(json['token']);
      return ApiResponse.success(UserModel.fromJson(json['user']));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  /// Returns the user plus whether they're brand new (needs onboarding)
  /// or existing (goes straight into the app).
  Future<ApiResponse<Map<String, dynamic>>> firebaseLogin({
    required String idToken,
  }) async {
    try {
      final json = await ApiClient.post('auth/firebase/verify', {
        'id_token': idToken,
      });
      await TokenStorage.saveToken(json['token']);

      return ApiResponse.success({
        'user': UserModel.fromJson(json['user']),
        'isNew': json['is_new'] as bool,
      });
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> chooseRole({required String role}) async {
    try {
      final json = await ApiClient.put('profile/choose-role', {'role': role});
      await TokenStorage.saveRole(role);
      return ApiResponse.success(UserModel.fromJson(json));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> setupProfile({
    String? name,
    String? displayName,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImage,
    String? farmName,
  }) async {
    try {
      final json = await ApiClient.put('profile/setup', {
        // ignore: use_null_aware_elements
        if (name != null) 'name': name,
        // ignore: use_null_aware_elements
        if (displayName != null) 'display_name': displayName,
        // ignore: use_null_aware_elements
        if (bio != null) 'bio': bio,
        // ignore: use_null_aware_elements
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        // ignore: use_null_aware_elements
        if (profileImage != null) 'profile_image': profileImage,
        // ignore: use_null_aware_elements
        if (farmName != null) 'farm_name': farmName,
      });
      return ApiResponse.success(UserModel.fromJson(json));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> setupLocation({
    required String province,
    String? district,
    String? commune,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final json = await ApiClient.put('profile/location', {
        'province': province,
        // ignore: use_null_aware_elements
        if (district != null) 'district': district,
        // ignore: use_null_aware_elements
        if (commune != null) 'commune': commune,
        // ignore: use_null_aware_elements
        if (latitude != null) 'latitude': latitude,
        // ignore: use_null_aware_elements
        if (longitude != null) 'longitude': longitude,
      });
      return ApiResponse.success(UserModel.fromJson(json));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<UserModel>> me() async {
    try {
      final json = await ApiClient.get('profile');
      return ApiResponse.success(UserModel.fromJson(json));
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message, errors: e.errors);
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('profile/logout');
    } on ApiException {
      // Even if the server call fails (e.g. token already expired),
      // clear local state so the user isn't stuck.
    }
    await TokenStorage.clear();
  }
}
