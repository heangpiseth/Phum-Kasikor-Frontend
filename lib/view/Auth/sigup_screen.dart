import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import '../../widgets/auth/auth_header.dart';

class SigupScreen extends StatelessWidget {
  const SigupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return AuthPage(
      showBack: true,

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 18),

            const AuthTitle(
              title: 'Create Account',
              subtitle: 'Join Phum Kasikor and support local farmers.',
            ),

            const SizedBox(height: 25),

            FarmTextField(
              label: 'Full name',
              hint: 'Sok Dara',
              prefixIcon: Icons.person_outline,
              controller: auth.signUpNameController,
            ),

            FarmTextField(
              label: 'Phone number',
              hint: '+855 12 345 678',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: auth.signUpPhoneController,
            ),

            FarmTextField(
              label: 'Email (optional)',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: auth.signUpEmailController,
            ),

            FarmTextField(
              label: 'Password',
              hint: 'Create a password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              controller: auth.signUpPasswordController,
            ),

            Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: auth.acceptedTerms.value,
                  activeColor: kFarmGreen,
                  onChanged: (value) => auth.acceptedTerms.value = value ?? false,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: TextStyle(fontSize: 11, color: kFarmMuted),
                    ),
                  ),
                ),
              ],
            )),

            Obx(() => auth.errorMessage.value != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.errorMessage.value!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 12),
            Obx(() => FarmButton(
              label: auth.isLoading.value ? 'Creating account...' : 'Create Account',
              onPressed: auth.isLoading.value ? null : auth.beginSignUp,
            )),
          ],
        ),
      ),
    );
  }
}