import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/farmer/user_model.dart';



import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class AuthController extends GetxController {
  // ============================================================
  // LOGIN
  // ============================================================

  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // ============================================================
  // SIGN UP
  // ============================================================

  final signUpNameController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  // ============================================================
  // PROFILE
  // ============================================================

  final profileNameController = TextEditingController();
  final farmNameController = TextEditingController();
  final bioController = TextEditingController();
  final addressController = TextEditingController();
  final profilePhoneController = TextEditingController();

  // ============================================================
  // LOCATION
  // ============================================================

  final provinceController = TextEditingController();

  final districtController = TextEditingController();
  final communeController = TextEditingController();

  // ============================================================
  // OTP
  // ============================================================

  final otpControllers = List.generate(6, (_) => TextEditingController());

  // ============================================================
  // STATE
  // ============================================================

  final selectedRole = UserRole.farmer.obs;

  final acceptedTerms = false.obs;

  final isLoading = false.obs;

  final resendSeconds = 45.obs;

  final errorMessage = RxnString();

  // ============================================================
  // INTERNAL DATA
  // ============================================================

  String? _pendingUserId;

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late final Future<void> _googleInit;

  // ============================================================
  // GETTERS
  // ============================================================

  String get phone {
    final signupPhone = signUpPhoneController.text.trim();

    if (signupPhone.isNotEmpty) {
      return signupPhone;
    }

    return loginPhoneController.text.trim();
  }

  String get otp {
    return otpControllers.map((controller) => controller.text.trim()).join();
  }

  final latitude = Rxn<double>();
  final longitude = Rxn<double>();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _googleInit = GoogleSignIn.instance.initialize(
      serverClientId:
          '392917185692-1olantat1oah94rnq10cjjt80vk4f3qm.apps.googleusercontent.com',
    );
  }

  // ============================================================
  // VALIDATE PHONE
  // ============================================================

  bool _validPhone(String value) {
    final digits = value.trim().replaceAll(RegExp(r'[^0-9]'), '');

    return digits.length >= 8;
  }

  // ============================================================
  // SHOW ERROR
  // ============================================================

  void _showError(String message) {
    errorMessage.value = message;

    Get.snackbar(
      'Something went wrong',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> beginLogin() async {
    debugPrint('========================================');
    debugPrint('>>> beginLogin() called');
    debugPrint('========================================');

    final identifier = loginPhoneController.text.trim();

    final password = loginPasswordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (identifier.isEmpty) {
      _showError('Please enter your phone number or email.');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    if (password.length < 8) {
      _showError('Your password must be at least 8 characters.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint('>>> Login identifier: $identifier');

      // --------------------------------------------------------
      // CALL LARAVEL
      // --------------------------------------------------------

      final response = await ApiClient.post('auth/login', {
        'identifier': identifier,
        'password': password,
      });

      debugPrint('>>> Login response: $response');

      if (response is! Map) {
        throw ApiException(500, 'Invalid login response from server.');
      }

      final json = Map<String, dynamic>.from(response);

      // --------------------------------------------------------
      // TOKEN
      // --------------------------------------------------------

      final token = json['token'];

      if (token == null || token.toString().isEmpty) {
        throw ApiException(
          500,
          'Login did not return an authentication token.',
        );
      }

      await TokenStorage.saveToken(token.toString());

      debugPrint('>>> Login token saved');

      // --------------------------------------------------------
      // USER
      // --------------------------------------------------------

      final userJson = json['user'];

      if (userJson is! Map) {
        throw ApiException(500, 'Login returned invalid user data.');
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

      debugPrint('>>> Logged in user: ${user.name}');

      debugPrint('>>> User role: ${user.role.name}');

      // --------------------------------------------------------
      // SAVE ROLE
      // --------------------------------------------------------

      await TokenStorage.saveRole(user.role.name);

      // --------------------------------------------------------
      // FINISH LOADING
      // --------------------------------------------------------

      isLoading.value = false;

      // --------------------------------------------------------
      // GO HOME
      // --------------------------------------------------------

      _goHome(user.role);
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Login API error: ${e.message}');

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> Login unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Login failed. Please try again.');
    }
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> beginSignUp() async {
    debugPrint('========================================');
    debugPrint('>>> beginSignUp() called');
    debugPrint('========================================');

    final name = signUpNameController.text.trim();

    final phone = signUpPhoneController.text.trim();

    final email = signUpEmailController.text.trim();

    final password = signUpPasswordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

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
      // --------------------------------------------------------
      // REQUEST BODY
      // --------------------------------------------------------

      final requestBody = <String, dynamic>{
        'name': name,
        'phone': phone,
        'password': password,
      };

      if (email.isNotEmpty) {
        requestBody['email'] = email;
      }

      debugPrint('>>> Register request: $requestBody');

      // --------------------------------------------------------
      // CALL LARAVEL
      // --------------------------------------------------------

      final response = await ApiClient.post('auth/register', requestBody);

      debugPrint('>>> Register response: $response');

      if (response is! Map) {
        throw ApiException(500, 'Invalid registration response from server.');
      }

      final json = Map<String, dynamic>.from(response);

      // --------------------------------------------------------
      // SAVE TOKEN
      // --------------------------------------------------------

      final token = json['token'];

      if (token != null && token.toString().isNotEmpty) {
        await TokenStorage.saveToken(token.toString());

        debugPrint('>>> Registration token saved');
      }

      // --------------------------------------------------------
      // GET USER ID
      // --------------------------------------------------------

      final userJson = json['user'];

      if (userJson is Map) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

        _pendingUserId = user.id;

        debugPrint('>>> Registered user ID: $_pendingUserId');
      } else if (json['user_id'] != null) {
        _pendingUserId = json['user_id'].toString();
      } else if (json['id'] != null) {
        _pendingUserId = json['id'].toString();
      }

      // --------------------------------------------------------
      // STOP LOADING
      // --------------------------------------------------------

      isLoading.value = false;

      // --------------------------------------------------------
      // CHECK USER ID
      // --------------------------------------------------------

      if (_pendingUserId == null || _pendingUserId!.isEmpty) {
        _showError(
          'Account was created, but the server did not return the user ID needed for verification.',
        );
        return;
      }

      // --------------------------------------------------------
      // GO TO OTP
      // --------------------------------------------------------

      Get.toNamed(AppRoutes.verification);
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Registration API error: ${e.message}');

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> Registration unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Registration failed. Please try again.');
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> verifyOtp() async {
    debugPrint('========================================');
    debugPrint('>>> verifyOtp() called');
    debugPrint('========================================');

    // ----------------------------------------------------------
    // VALIDATE OTP
    // ----------------------------------------------------------

    if (otp.length != 6) {
      _showError('Enter the complete 6-digit verification code.');
      return;
    }

    // ----------------------------------------------------------
    // CHECK USER ID
    // ----------------------------------------------------------

    if (_pendingUserId == null || _pendingUserId!.isEmpty) {
      _showError('Something went wrong. Please sign up again.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint('>>> Verifying OTP for user: $_pendingUserId');

      // --------------------------------------------------------
      // CALL LARAVEL
      // --------------------------------------------------------

      final response = await ApiClient.post('auth/verify', {
        'user_id': _pendingUserId,
        'code': otp,
      });

      debugPrint('>>> OTP response: $response');

      // --------------------------------------------------------
      // SAVE TOKEN IF SERVER RETURNS ONE
      // --------------------------------------------------------

      if (response is Map) {
        final json = Map<String, dynamic>.from(response);

        final token = json['token'];

        if (token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveToken(token.toString());
        }
      }

      isLoading.value = false;

      // --------------------------------------------------------
      // GO TO ROLE SELECTION
      // --------------------------------------------------------

      Get.offNamed(AppRoutes.roleSelection);
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> OTP API error: ${e.message}');

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> OTP unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Unable to verify your account. Please try again.');
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  void resendOtp() {
    resendSeconds.value = 45;

    Get.snackbar(
      'Code sent',
      'A new verification code was sent to $phone.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<void> signInWithGoogle() async {
    debugPrint('========================================');
    debugPrint('>>> signInWithGoogle() called');
    debugPrint('========================================');

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // --------------------------------------------------------
      // INITIALIZE GOOGLE
      // --------------------------------------------------------

      await _googleInit;

      debugPrint('>>> Google Sign-In initialized');

      // --------------------------------------------------------
      // GOOGLE ACCOUNT PICKER
      // --------------------------------------------------------

      final googleUser = await GoogleSignIn.instance.authenticate();

      debugPrint('>>> Google account selected');

      // --------------------------------------------------------
      // GOOGLE ID TOKEN
      // --------------------------------------------------------

      final idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw ApiException(500, 'Failed to get Google ID token.');
      }

      debugPrint('>>> Google ID token received');

      // --------------------------------------------------------
      // FIREBASE GOOGLE CREDENTIAL
      // --------------------------------------------------------

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // --------------------------------------------------------
      // SIGN INTO FIREBASE
      // --------------------------------------------------------

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      debugPrint('>>> Firebase Google sign-in successful');

      // --------------------------------------------------------
      // FIREBASE ID TOKEN
      // --------------------------------------------------------

      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw ApiException(500, 'Failed to get Firebase ID token.');
      }

      debugPrint('>>> Firebase ID token received');

      // --------------------------------------------------------
      // SEND FIREBASE TOKEN TO LARAVEL
      // --------------------------------------------------------

      final response = await ApiClient.post('auth/firebase/verify', {
        'id_token': firebaseIdToken,
      });

      debugPrint('>>> Laravel Firebase response: $response');

      if (response is! Map) {
        throw ApiException(500, 'Invalid Firebase authentication response.');
      }

      final json = Map<String, dynamic>.from(response);

      // --------------------------------------------------------
      // SANCTUM TOKEN
      // --------------------------------------------------------

      final token = json['token'];

      if (token == null || token.toString().isEmpty) {
        throw ApiException(
          500,
          'Google authentication did not return a token.',
        );
      }

      await TokenStorage.saveToken(token.toString());

      debugPrint('>>> Laravel Sanctum token saved');

      // --------------------------------------------------------
      // USER
      // --------------------------------------------------------

      final userJson = json['user'];

      if (userJson is! Map) {
        throw ApiException(
          500,
          'Google authentication returned invalid user data.',
        );
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

      // --------------------------------------------------------
      // NEW ACCOUNT?
      // --------------------------------------------------------

      final isNew = json['is_new'] as bool? ?? false;

      debugPrint('>>> Google user isNew: $isNew');

      isLoading.value = false;

      // --------------------------------------------------------
      // NEW GOOGLE USER
      // --------------------------------------------------------

      if (isNew) {
        Get.offNamed(AppRoutes.roleSelection);
        return;
      }

      // --------------------------------------------------------
      // EXISTING GOOGLE USER
      // --------------------------------------------------------

      await TokenStorage.saveRole(user.role.name);

      _goHome(user.role);
    } on Exception catch (e) {
      isLoading.value = false;

      debugPrint('>>> Google Sign-In error: $e');

      if (e.toString().contains('canceled') || e.toString().contains('CANCELED')) {
        return;
      }

      _showError('Google sign-in failed. Please try again.');
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Google API error: ${e.message}');

      _showError(e.message);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Firebase error: ${e.code}');

      _showError(e.message ?? 'Firebase authentication failed.');
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> Google unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Google sign-in failed. Please try again.');
    }
  }

  // ============================================================
  // CHOOSE ROLE
  // ============================================================

  Future<void> submitRole() async {
    debugPrint('========================================');
    debugPrint('>>> submitRole() called');
    debugPrint('>>> Role: ${selectedRole.value.name}');
    debugPrint('========================================');

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // --------------------------------------------------------
      // SAVE ROLE TO LARAVEL
      // --------------------------------------------------------

      final response = await ApiClient.put('profile/choose-role', {
        'role': selectedRole.value.name,
      });

      debugPrint('>>> Choose role response: $response');

      // --------------------------------------------------------
      // SAVE ROLE LOCALLY
      // --------------------------------------------------------

      await TokenStorage.saveRole(selectedRole.value.name);

      isLoading.value = false;

      // --------------------------------------------------------
      // FARMER
      // --------------------------------------------------------

      if (selectedRole.value == UserRole.farmer) {
        Get.toNamed(AppRoutes.profileSetup);
        return;
      }

      // --------------------------------------------------------
      // CUSTOMER
      // --------------------------------------------------------

      Get.offAllNamed(AppRoutes.costumerHomescreen);
    } on ApiException catch (e) {
      isLoading.value = false;

      debugPrint('>>> Role API error: ${e.message}');

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> Role unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Unable to save your role. Please try again.');
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> saveProfile() async {
    final name = profileNameController.text.trim();

    if (name.isEmpty) {
      _showError('Your full name is required.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final farmName = farmNameController.text.trim();

      final bio = bioController.text.trim();

      final body = <String, dynamic>{'name': name};

      if (bio.isNotEmpty) {
        body['bio'] = bio;
      }

      if (selectedRole.value == UserRole.farmer && farmName.isNotEmpty) {
        body['farm_name'] = farmName;
      }

      debugPrint('>>> Profile request: $body');

      final response = await ApiClient.put('profile/setup', body);

      debugPrint('>>> Profile response: $response');

      isLoading.value = false;

      Get.toNamed(AppRoutes.locationSetup);
    } on ApiException catch (e) {
      isLoading.value = false;

      _showError(e.message);
    } catch (e, stackTrace) {
      isLoading.value = false;

      debugPrint('>>> Profile unexpected error: $e');

      debugPrint('>>> Stack trace: $stackTrace');

      _showError('Unable to save your profile. Please try again.');
    }
  }

  // ============================================================
  // COMPLETE LOCATION
  // ============================================================

  Future<void> completeLocation() async {
    errorMessage.value = null;

    final lat = latitude.value;
    final lng = longitude.value;

    if (lat == null || lng == null) {
      errorMessage.value = 'Please select your farm location on the map.';
      return;
    }

    final province = provinceController.text.trim();

    final district = districtController.text.trim();

    final commune = communeController.text.trim();

    // Province is required by the Laravel API.
    if (province.isEmpty) {
      errorMessage.value =
          'Could not detect your province. '
          'Please move the pin to your farm location.';
      return;
    }

    // ============================================================
    // REQUEST BODY
    // ============================================================

    final body = <String, dynamic>{
      'province': province,
      'latitude': lat,
      'longitude': lng,
    };

    // Only send district when available.
    if (district.isNotEmpty) {
      body['district'] = district;
    }

    // Only send commune when available.
    if (commune.isNotEmpty) {
      body['commune'] = commune;
    }

    // ============================================================
    // SEND TO LARAVEL
    // ============================================================

    debugPrint('========== LOCATION REQUEST ==========');
    debugPrint('URL: profile/location');
    debugPrint('BODY: $body');
    debugPrint('LAT: $lat');
    debugPrint('LNG: $lng');
    debugPrint('PROVINCE: $province');
    debugPrint('DISTRICT: $district');
    debugPrint('COMMUNE: $commune');

    try {
      final response = await ApiClient.put('profile/location', body);
      debugPrint('========== LOCATION RESPONSE ==========');
      debugPrint('${response}');

      errorMessage.value = null;

      // ==========================================================
      // GO TO NEXT SCREEN
      // ==========================================================

      Get.offAllNamed(AppRoutes.farmerHome);
    } on ApiException catch (e) {
      debugPrint('========== API ERROR ==========');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('ERROR: $e');

      errorMessage.value = e.message;
    } catch (e) {
      
      errorMessage.value = 'Location save failed: $e';
    }
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  void _goHome(UserRole role) {
    debugPrint('>>> Going home with role: ${role.name}');

    Get.offAllNamed(
      role == UserRole.farmer
          ? AppRoutes.farmerHome
          : AppRoutes.costumerHomescreen,
    );
  }

  // ============================================================
  // CLEAN UP
  // ============================================================

  @override
  void onClose() {
    loginPhoneController.dispose();
    loginPasswordController.dispose();

    signUpNameController.dispose();
    signUpPhoneController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();

    profileNameController.dispose();
    farmNameController.dispose();
    bioController.dispose();
    addressController.dispose();
    profilePhoneController.dispose();

    provinceController.dispose();
    districtController.dispose();
    communeController.dispose();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    super.onClose();
  }

  void setLocation(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
  }
}
