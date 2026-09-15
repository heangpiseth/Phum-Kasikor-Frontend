import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/farmer/user_model.dart';
import 'package:phum_kasikors/view/costumer/costumer_home_screen.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../view/Farmer/farmer_home_screen.dart';

class AuthController extends GetxController {
  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final profileNameController = TextEditingController();
  final farmNameController = TextEditingController();
  final bioController = TextEditingController();
  final addressController = TextEditingController();
  final profilePhoneController = TextEditingController();
  final provinceController = TextEditingController(text: 'Phnom Penh');
  final districtController = TextEditingController();
  final communeController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  final selectedRole = UserRole.farmer.obs;
  final acceptedTerms = false.obs;
  final isLoading = false.obs;
  final resendSeconds = 45.obs;
  final errorMessage = RxnString();

  // Set once /register succeeds - needed by verifyOtp() to identify
  // which account the code belongs to.
  String? _pendingUserId;

  final _firebaseAuth = FirebaseAuth.instance;
  late final Future<void> _googleInit;

  @override
  void onInit() {
    super.onInit();
    _googleInit = GoogleSignIn.instance.initialize(
      serverClientId:
          '392917185692-1olantat1oah94rnq10cjjt80vk4f3qm.apps.googleusercontent.com',
    );
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _googleInit;

      final googleUser = await GoogleSignIn.instance.authenticate();

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        isLoading.value = false;
        _showError('Failed to get Google ID token.');
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        isLoading.value = false;
        _showError('Failed to get Firebase ID token.');
        return;
      }

      final json = await ApiClient.post('auth/firebase/verify', {
        'id_token': firebaseIdToken,
      });

      // ⭐️ SAFE TOKEN HANDLING
      final token = json['token'];

      if (token == null) {
        throw ApiException(
          500,
          'Google authentication did not return a token.',
        );
      }

      await TokenStorage.saveToken(token.toString());

      // ⭐️ SAFE USER HANDLING
      final userJson = json['user'];

      if (userJson is! Map) {
        throw ApiException(
          500,
          'Google authentication returned invalid user data.',
        );
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

      final isNew = json['is_new'] as bool? ?? false;

      isLoading.value = false;

      if (isNew) {
        Get.toNamed(AppRoutes.roleSelection);
        return;
      }

      await TokenStorage.saveRole(user.role.name);

      _goHome(user.role);
    } on GoogleSignInException catch (e) {
      isLoading.value = false;
 if (e.code != GoogleSignInExceptionCode.canceled) {
        _showError('Google sign-in failed. Please try again.');
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      _showError(e.message);
    } catch (e) {
      isLoading.value = false;
      _showError('Google sign-in failed: ${e.toString()}');
    }
  }

  String get phone => signUpPhoneController.text.trim().isNotEmpty
      ? signUpPhoneController.text.trim()
      : loginPhoneController.text.trim();
  String get otp => otpControllers.map((controller) => controller.text).join();

  bool _validPhone(String value) =>
      value.trim().replaceAll(RegExp(r'[^0-9]'), '').length >= 8;

  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Check your details',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Logs in directly against the real backend - no OTP needed, since
  /// /login issues a token immediately for an already-verified account.
  Future<void> beginLogin() async {
    if (!_validPhone(loginPhoneController.text) || loginPasswordController.text.trim().length < 8) {
      _showError(
        'Enter a valid phone number and a password of at least 8 characters.',
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final json = await ApiClient.post('auth/login', {
        'identifier': loginPhoneController.text.trim(),
        'password': loginPasswordController.text,
      });

      await TokenStorage.saveToken(json['token'] as String);
      final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);

      isLoading.value = false;

      await TokenStorage.saveRole(user.role.name);
      _goHome(user.role);
    } on ApiException catch (e) {
      isLoading.value = false;
      _showError(e.message);
    }
  }

  Future<void> beginSignUp() async {
    debugPrint('>>> beginSignUp() called');

    final name = signUpNameController.text.trim();
    final phone = signUpPhoneController.text.trim();
    final email = signUpEmailController.text.trim();
    final password = signUpPasswordController.text;

    // -----------------------------
    // Validate signup form
    // -----------------------------

    if (name.isEmpty) {
      _showError('Please enter your full name.');
      return;
    }

    if (!_validPhone(phone)) {
      _showError('Please enter a valid phone number.');
      return;
    }

    if (password.length < 8) {
      _showError('Your password must be at least 8 characters.');
      return;
    }

    if (!acceptedTerms.value) {
      _showError('Please accept the Terms of Service and Privacy Policy.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final requestBody = <String, dynamic>{
        'name': name,
        'phone': phone,
        'password': password,
      };

      if (email.isNotEmpty) {
        requestBody['email'] = email;
      }

      debugPrint('>>> Register request: $requestBody');

      final response = await ApiClient.post('auth/register', requestBody);

      debugPrint('>>> Register response: $response');

      if (response is! Map) {
        throw ApiException(500, 'Invalid registration response from server.');
      }

      final json = Map<String, dynamic>.from(response);

      // -----------------------------------------
      // Save token if Laravel returned one
      // -----------------------------------------

      final token = json['token'];

      if (token != null && token.toString().isNotEmpty) {
        await TokenStorage.saveToken(token.toString());
        debugPrint('>>> Registration token saved');
      } else {
        debugPrint('>>> Registration did not return a token');
      }

      // -----------------------------------------
      // Read user if Laravel returned one
      // -----------------------------------------

      final userJson = json['user'];

      if (userJson is Map) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

        _pendingUserId = user.id;

        debugPrint('>>> Registered user ID: ${user.id}');
      } else if (json['user_id'] != null) {
        _pendingUserId = json['user_id'].toString();

        debugPrint('>>> Registered user ID: $_pendingUserId');
      } else if (json['id'] != null) {
        _pendingUserId = json['id'].toString();

        debugPrint('>>> Registered user ID: $_pendingUserId');
      }

      isLoading.value = false;

      // -----------------------------------------
      // Make sure we have a user ID for OTP
      // -----------------------------------------

      if (_pendingUserId == null) {
        _showError(
          'Account was created, but the server did not return the user ID needed for verification.',
        );
        return;
      }

      // -----------------------------------------
      // Go to OTP screen
      // -----------------------------------------

      Get.toNamed(AppRoutes.verification);
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Registration API error: ${e.message}');

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('========================================');
      debugPrint('>>> REGISTRATION UNEXPECTED ERROR');
      debugPrint('>>> ERROR: $e');
      debugPrint('>>> ERROR TYPE: ${e.runtimeType}');
      debugPrint('>>> STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('========================================');

      _showError('Registration failed: ${e.toString()}');
    }
  }

  Future<void> verifyOtp() async {
    if (otp.length != 6) {
      _showError('Enter the complete 6-digit verification code.');
      return;
    }

    if (_pendingUserId == null || _pendingUserId!.isEmpty) {
      _showError('Something went wrong. Please sign up again.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint('>>> Verifying OTP for user: $_pendingUserId');

      final response = await ApiClient.post('auth/verify', {
        'user_id': _pendingUserId,
        'code': otp,
      });

      debugPrint('>>> OTP response: $response');

      // -------------------------------------
      // If verification returns a token,
      // save it.
      // -------------------------------------

      if (response is Map) {
        final json = Map<String, dynamic>.from(response);

        final token = json['token'];

        if (token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveToken(token.toString());
        }
      }

      isLoading.value = false;

      Get.offNamed(AppRoutes.roleSelection);
    } on ApiException catch (e) {
      isLoading.value = false;

      _showError(e.message);
    } catch (e) {
      isLoading.value = false;

      debugPrint('>>> OTP unexpected error: $e');

      _showError('Unable to verify your account. Please try again.');
    }
  }

  void resendOtp() {
    resendSeconds.value = 45;
    Get.snackbar('Code sent', 'A new verification code was sent to $phone.');
  }

  /// Submits the chosen role - called from ChooseRoleScreen's Continue button.
  Future<void> submitRole() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await ApiClient.put('profile/choose-role', {
        'role': selectedRole.value.name,
      });
      await TokenStorage.saveRole(selectedRole.value.name);

      isLoading.value = false;
      Get.toNamed(AppRoutes.profileSetup);
    } on ApiException catch (e) {
      isLoading.value = false;
      _showError(e.message);
    }
  }

  Future<void> saveProfile() async {
    if (profileNameController.text.trim().isEmpty) {
      _showError('Your full name is required.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final farmName = farmNameController.text.trim();
      final bio = bioController.text.trim();
await ApiClient.put('profile/setup', {
        'name': profileNameController.text.trim(),
        if (bio.isNotEmpty) 'bio': bio,
        if (selectedRole.value == UserRole.farmer && farmName.isNotEmpty)
          'farm_name': farmName,
      });

      isLoading.value = false;
      Get.toNamed(AppRoutes.locationSetup);
    } on ApiException catch (e) {
      isLoading.value = false;
      _showError(e.message);
    }
  }

  Future<void> completeLocation() async {
    if (provinceController.text.trim().isEmpty) {
      _showError('Choose your province or city first.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final district = districtController.text.trim();
      final commune = communeController.text.trim();

      final response = await ApiClient.put('profile/location', {
        'province': provinceController.text.trim(),
        if (district.isNotEmpty) 'district': district,
        if (commune.isNotEmpty) 'commune': commune,
      });

      debugPrint('>>> Location response: $response');

      if (response is! Map) {
        throw ApiException(500, 'Invalid location response from server.');
      }

      final json = Map<String, dynamic>.from(response);

      final userJson = json['user'];

      UserModel user;

      if (userJson is Map) {
        user = UserModel.fromJson(Map<String, dynamic>.from(userJson));
      } else {
        user = UserModel.fromJson(json);
      }

      await TokenStorage.saveRole(user.role.name);

      isLoading.value = false;

      _goHome(user.role);
    } on ApiException catch (e) {
      isLoading.value = false;
      _showError(e.message);
    } catch (e) {
      isLoading.value = false;

      debugPrint('>>> Location unexpected error: $e');

      _showError('Unable to save your location. Please try again.');
    }
  }

  void _goHome(UserRole role) {
    Get.offAll(
      () => role == UserRole.farmer
          ? const FarmerHomeScreen()
          : const CostumerHomeScreen(),
    );
  }

  @override
  void onClose() {
    for (final controller in [
      loginPhoneController,
      loginPasswordController,
      signUpNameController,
      signUpPhoneController,
      signUpEmailController,
      signUpPasswordController,
      profileNameController,
      farmNameController,
      bioController,
      addressController,
      profilePhoneController,
      provinceController,
      districtController,
      communeController,
      ...otpControllers,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}