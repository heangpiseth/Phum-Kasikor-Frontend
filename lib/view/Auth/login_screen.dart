import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color primaryGreen = Color(0xFF3D7A4A);
  static const Color darkGreen = Color(0xFF2F693D);
  static const Color lightGreen = Color(0xFF4F8D5B);

  static const Color textDark = Color(0xFF18231C);
  static const Color muted = Color(0xFF68736B);
  static const Color border = Color(0xFFDDE3DE);
  static const Color pageBackground = Color(0xFFF7F8F3);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: pageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ============================================================
            // BACKGROUND HEADER
            // ============================================================

            _buildHeader(context),

            // ============================================================
            // FORM SHEET
            // ============================================================

            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.67,
                widthFactor: 1,
                child: _buildForm(context, auth),
              ),
            ),

            // ============================================================
            // BACK BUTTON
            // ============================================================

            Positioned(
              top: 8,
              left: 12,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightGreen,
            darkGreen,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(55),
          bottomRight: Radius.circular(55),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -45,
            top: 35,
            child: _circle(155),
          ),

          Positioned(
            right: 30,
            bottom: -55,
            child: _circle(120),
          ),

          // Leaf
          Positioned(
            left: 42,
            top: 145,
            child: Icon(
              Icons.eco_outlined,
              color: Colors.white.withValues(alpha: 0.28),
              size: 48,
            ),
          ),

          // ============================================================
          // HEADER TEXT
          // ============================================================

          Positioned(
            left: 30,
            bottom: 72,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hello',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                Text(
                  'Sign in!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome back to Phum Kasikor',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }

  // ==========================================================================
  // FORM
  // ==========================================================================

  Widget _buildForm(
    BuildContext context,
    AuthController auth,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          28,
          32,
          28,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // FORM HEADER
            // ============================================================

            const Text(
              'Sign in to continue',
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Enter your details below to access your account.',
              style: TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 26),

            // ============================================================
            // PHONE
            // ============================================================

            _buildTextField(
              label: 'Phone number',
              hint: '+855 12 345 678',
              icon: Icons.phone_outlined,
              controller: auth.loginPhoneController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 18),

            // ============================================================
            // PASSWORD
            // ============================================================

            _buildTextField(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              controller: auth.loginPasswordController,
              obscureText: true,
            ),

            // ============================================================
            // FORGOT PASSWORD
            // ============================================================

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ============================================================
            // ERROR FROM BACKEND
            // ============================================================

            Obx(() {
              final error = auth.errorMessage.value;

              if (error == null || error.trim().isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFFF0CCC7),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFC65346),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Color(0xFFC65346),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ============================================================
            // LOGIN BUTTON
            // ============================================================

            Obx(
              () => _primaryButton(
                text: 'Log in',
                loadingText: 'Logging in...',
                loading: auth.isLoading.value,
                onPressed: auth.isLoading.value
                    ? null
                    : auth.beginLogin,
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // OR
            // ============================================================

            Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: border,
                    thickness: 1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pageBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'OR',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: border,
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ============================================================
            // GOOGLE
            // ============================================================

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 53,
                child: OutlinedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : auth.signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: border,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 27,
                        height: 27,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: pageBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // SIGN UP
            // ============================================================

            Center(
              child: GestureDetector(
                onTap: () => Get.offNamed(AppRoutes.signup),
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TEXT FIELD
  // ==========================================================================

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction:
          obscureText ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: primaryGreen,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: primaryGreen,
          size: 21,
        ),
        labelStyle: const TextStyle(
          color: muted,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryGreen,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFB2BAB4),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 15,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: border,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: border,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUTTON
  // ==========================================================================

  Widget _primaryButton({
    required String text,
    required String loadingText,
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          disabledBackgroundColor:
              primaryGreen.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}