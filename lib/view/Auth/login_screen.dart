import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import '../../widgets/auth/auth_header.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AuthPage(
      showBack: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            const AuthBrand(compact: true),
            const SizedBox(height: 28),
            const AuthTitle(
              title: 'Welcome Back!',
              subtitle: 'Log in to continue shopping local.',
            ),
            const SizedBox(height: 28),
            FarmTextField(
              label: 'Phone number',
              hint: '+855 12 345 678',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: auth.loginPhoneController,
            ),
            FarmTextField(
              label: 'Password',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              controller: auth.loginPasswordController,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: kFarmGreen),
                ),
              ),
            ),
            Obx(() => auth.errorMessage.value != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.errorMessage.value!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 12),
            Obx(() => FarmButton(
              label: auth.isLoading.value ? 'Logging in...' : 'Log in',
              onPressed: auth.isLoading.value ? null : auth.beginLogin,
            )),
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: TextStyle(fontSize: 12, color: kFarmMuted),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            Obx(() => Row(
              children: [
                Expanded(
                  child: FarmButton(
                    label: 'Google',
                    outlined: true,
                    onPressed: auth.isLoading.value ? null : auth.signInWithGoogle,
                  ),
                ),
              ],
            )),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => Get.offNamed('/sign-up'),
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: kFarmGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}