import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import 'package:phum_kasikors/view/Auth/login_screen.dart';
import 'package:phum_kasikors/view/Auth/sigup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.055),
                Container(
                  width: double.infinity,
                  height: size.height * 0.30,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(10),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),

                      child: Image.asset(
                        'assets/cashew.jpg',
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'សូមស្វាគមន៍មកកាន់ ភូមិកសិករ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 5),
                const Text(
                  'Empowering local agriculture, nourishing\nCambodian families.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => LoginScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),

                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
 const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => const SigupScreen());
                    },

                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: AppColors.primary,

                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),

                    child: const Text(
                      'Create Account',

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const Text(
                  'OR SIGN IN WITH',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 12),
                Obx(
                  () => auth.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: CircularProgressIndicator(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Facebook - not wired up yet, kept visually for layout
                            _socialImageButton(
                              image: 'assets/facebook.jpg',
                              onTap: () {
                                Get.snackbar('Coming soon', 'Facebook sign-in is not available yet.');
                              },
                            ),
                            SizedBox(width: 14),
 // Google
                            _socialImageButton(
                              image: 'assets/google.jpg',
                              onTap: () {
                                auth.signInWithGoogle();
                              },
                            ),
                            SizedBox(width: 14),
                          ],
                        ),
                ),
                // Display error messages
                Obx(
                  () => auth.errorMessage.value != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(
                              auth.errorMessage.value!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Get.to(() => CostumerHomeScreen());
                  },

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  child: const Text(
                    'Continue as Guest',

                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _socialImageButton({
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(10),

      child: Container(
        width: 46,
        height: 40,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}