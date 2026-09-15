import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/auth_controller.dart';
import '../../widgets/auth/auth_header.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return AuthPage(
      showBack: true,
      child: Column(
        children: [
          const Spacer(),
          const AuthIllustration(
            icon: Icons.phonelink_lock_rounded,
            color: Color(0xFFC8F1F5),
          ),
          const SizedBox(height: 32),
          AuthTitle(
            center: true,
            title: 'OTP Verification',
            subtitle: 'Enter the 6-digit code sent to ${auth.phone}',
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: 42,
                child: TextField(
                  controller: auth.otpControllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => auth.errorMessage.value != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(auth.errorMessage.value!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                )
              : const SizedBox.shrink()),
          Obx(() => auth.resendSeconds.value > 0
              ? Text(
                  'Resend code in 00:${auth.resendSeconds.value.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: kFarmMuted, fontSize: 12),
                )
              : TextButton(onPressed: auth.resendOtp, child: const Text('Resend code'))),
          const SizedBox(height: 20),
          Obx(() => FarmButton(
            label: auth.isLoading.value ? 'Verifying...' : 'Verify',
            onPressed: auth.isLoading.value ? null : auth.verifyOtp,
          )),
          const Spacer(),
        ],
      ),
    );
  }
}